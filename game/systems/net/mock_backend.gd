class_name MockBackend
extends RefCounted
## Backend IN-MEMORY = mirror logic của Supabase Edge Functions (P6 Server-Assisted, headless-testable).
## Là "single source of truth" cho leaderboard/guild-boss-HP/pvp/cloud-save; DEDUPE theo command_id;
## VERIFY bằng chạy lại BattleSim seeded (chống điểm giả / snapshot chỉnh). Production: thay bằng HTTP
## adapter tới Edge Function cùng logic (rules/multiplayer.md "Never trust client").

const RATE_CAP := 30                     # trần lệnh/loại/account (chống spam) — reset qua reset_rates()

var leaderboards: Dictionary = {}        # season_key -> {account -> {score, seed}}
var guilds: Dictionary = {}              # guild_id -> {name, level, guild_coin, boss_hp_current, boss_hp_max}
var guild_members: Dictionary = {}       # guild_id -> {account -> {role, contribution}}
var pvp_defenses: Dictionary = {}        # account -> {snapshot, stat_hash}
var pvp_matches: Dictionary = {}         # match_id -> result
var cloud_saves: Dictionary = {}         # account -> {blob, checksum, version, updated_at, play_time}
var _processed: Dictionary = {}          # command_id -> CommandResult (idempotency)
var _names: Dictionary = {}              # guild name -> guild_id (unique)
var _rate: Dictionary = {}               # "account:type" -> count
var _guild_seq: int = 0

## Điểm vào duy nhất (như invoke_edge). cmd: GameCommand. Trả CommandResult.
func invoke(cmd: GameCommand) -> CommandResult:
	if cmd.command_id != "" and _processed.has(cmd.command_id):
		return _processed[cmd.command_id]          # idempotent: trả kết quả cũ, KHÔNG xử lại
	if not _rate_ok(cmd):
		return CommandResult.rejected("rate_limited", CommandResult.Code.REJECTED_RATE)
	var res := _dispatch(cmd)
	if cmd.command_id != "":
		_processed[cmd.command_id] = res
	return res

func _dispatch(cmd: GameCommand) -> CommandResult:
	match str(cmd.type):
		"lb-submit": return _lb_submit(cmd.payload)
		"save-upload": return _save_upload(cmd.payload)
		"save-download": return _save_download(cmd.payload)
		"guild-create": return _guild_create(cmd.payload)
		"guild-join": return _guild_join(cmd.payload)
		"guild-boss-hit": return _guild_boss_hit(cmd.payload)
		"guild-shop-buy": return _guild_shop_buy(cmd.payload)
		"pvp-defense-set": return _pvp_defense_set(cmd.payload)
		"pvp-submit": return _pvp_submit(cmd.payload)
		"claim-reward": return CommandResult.new(CommandResult.Code.OK, {"authorized": true})
		_: return CommandResult.rejected("unknown_fn", CommandResult.Code.ERROR)

# --- leaderboard: verify score bằng chạy lại trận seeded ---------------------
func _lb_submit(p: Dictionary) -> CommandResult:
	var expected := _battle_score(p.get("team", []), p.get("opponent", []), int(p.get("seed", 0)),
		str(p.get("formation_a", "balanced_3")), str(p.get("formation_b", "balanced_3")))
	if int(p.get("score", -1)) != expected:
		return CommandResult.rejected("score_mismatch")     # chống điểm giả
	var sk := str(p.get("season_key", "s0"))
	var acc := str(p.get("account_id", ""))
	var board: Dictionary = leaderboards.get(sk, {})
	if not board.has(acc) or expected > int(board[acc]["score"]):
		board[acc] = {"score": expected, "seed": int(p.get("seed", 0))}
	leaderboards[sk] = board
	return CommandResult.new(CommandResult.Code.OK, {"score": expected})

func top(season_key: String, n: int = 10) -> Array:
	var board: Dictionary = leaderboards.get(season_key, {})
	var rows: Array = []
	for acc in board:
		rows.append({"account_id": acc, "score": int(board[acc]["score"])})
	rows.sort_custom(func(a, b): return a["score"] > b["score"] or (a["score"] == b["score"] and a["account_id"] < b["account_id"]))
	for i in rows.size():
		rows[i]["rank"] = i + 1
	return rows.slice(0, n)

# --- cloud save: checksum + chống tụt tiến trình + conflict -----------------
func _save_upload(p: Dictionary) -> CommandResult:
	var acc := str(p.get("account_id", ""))
	var blob = p.get("blob", {})
	var checksum := str(p.get("checksum", ""))
	if checksum != _checksum(blob):
		return CommandResult.rejected("checksum_failed")           # integrity fail
	var play_time := int(p.get("play_time", 0))
	var base_updated := int(p.get("base_updated_at", 0))
	var existing = cloud_saves.get(acc)
	if existing != null:
		if play_time < int(existing["play_time"]):
			return CommandResult.rejected("progress_regression")   # anti-cheat: tiến trình tụt bất thường
		if int(existing["updated_at"]) > base_updated:
			return CommandResult.new(CommandResult.Code.OK, {"conflict": true, "cloud_meta": _meta(existing)})
	var updated := base_updated + 1
	cloud_saves[acc] = {"blob": blob, "checksum": checksum, "version": int(p.get("save_version", 1)),
		"updated_at": updated, "play_time": play_time}
	return CommandResult.new(CommandResult.Code.OK, {"conflict": false, "updated_at": updated})

func _save_download(p: Dictionary) -> CommandResult:
	var existing = cloud_saves.get(str(p.get("account_id", "")))
	if existing == null:
		return CommandResult.new(CommandResult.Code.OK, {"exists": false})
	return CommandResult.new(CommandResult.Code.OK, {"exists": true, "blob": existing["blob"], "meta": _meta(existing)})

# --- guild -----------------------------------------------------------------
func _guild_create(p: Dictionary) -> CommandResult:
	var nm := str(p.get("name", ""))
	if _names.has(nm):
		return CommandResult.rejected("name_taken")
	var gid := "guild_%d" % _guild_seq
	_guild_seq += 1
	guilds[gid] = {"name": nm, "level": 1, "guild_coin": 0, "boss_hp_current": 100000, "boss_hp_max": 100000}
	guild_members[gid] = {str(p.get("account_id", "")): {"role": "Leader", "contribution": 0}}
	_names[nm] = gid
	return CommandResult.new(CommandResult.Code.OK, {"guild_id": gid})

func _guild_join(p: Dictionary) -> CommandResult:
	var gid := str(p.get("guild_id", ""))
	if not guilds.has(gid):
		return CommandResult.rejected("no_guild")
	var members: Dictionary = guild_members.get(gid, {})
	members[str(p.get("account_id", ""))] = {"role": "Member", "contribution": 0}
	guild_members[gid] = members
	return CommandResult.new(CommandResult.Code.OK, {"role": "Member"})

## Cộng damage vào shared-HP SERVER-SIDE (client KHÔNG tự trừ HP boss).
func _guild_boss_hit(p: Dictionary) -> CommandResult:
	var gid := str(p.get("guild_id", ""))
	var g = guilds.get(gid)
	if g == null:
		return CommandResult.rejected("no_guild")
	var dmg := maxi(0, int(p.get("damage", 0)))
	g["boss_hp_current"] = maxi(0, int(g["boss_hp_current"]) - dmg)
	var acc := str(p.get("account_id", ""))
	var members: Dictionary = guild_members.get(gid, {})
	if members.has(acc):
		members[acc]["contribution"] = int(members[acc]["contribution"]) + dmg
	return CommandResult.new(CommandResult.Code.OK, {"boss_hp_current": int(g["boss_hp_current"]), "contribution": dmg})

func _guild_shop_buy(p: Dictionary) -> CommandResult:
	var gid := str(p.get("guild_id", ""))
	var g = guilds.get(gid)
	if g == null:
		return CommandResult.rejected("no_guild")
	var cost := int(p.get("cost", 0))
	if int(g["guild_coin"]) < cost:
		return CommandResult.rejected("insufficient_coin")
	g["guild_coin"] = int(g["guild_coin"]) - cost
	return CommandResult.new(CommandResult.Code.OK, {"guild_coin": int(g["guild_coin"])})

func grant_guild_coin(gid: String, n: int) -> void:
	if guilds.has(gid):
		guilds[gid]["guild_coin"] = int(guilds[gid]["guild_coin"]) + n

# --- async PvP: verify snapshot chưa chỉnh + chạy lại seeded -----------------
func _pvp_defense_set(p: Dictionary) -> CommandResult:
	pvp_defenses[str(p.get("account_id", ""))] = {"snapshot": p.get("snapshot", {}), "stat_hash": str(p.get("stat_hash", ""))}
	return CommandResult.new(CommandResult.Code.OK, {})

func _pvp_submit(p: Dictionary) -> CommandResult:
	var did := str(p.get("defender_id", ""))
	var stored = pvp_defenses.get(did)
	if stored == null:
		return CommandResult.rejected("no_defender")
	if str(p.get("defender_stat_hash", "")) != str(stored["stat_hash"]):
		return CommandResult.rejected("snapshot_tampered")        # snapshot bị chỉnh
	var def_heroes: Array = (stored["snapshot"] as Dictionary).get("heroes", [])
	var res := _run(p.get("attacker_team", []), def_heroes, int(p.get("seed", 0)),
		str(p.get("formation_a", "balanced_3")), str((stored["snapshot"] as Dictionary).get("formation_id", "balanced_3")))
	var attacker_won := res.winner == 0
	var mid := str(p.get("match_id", ""))
	pvp_matches[mid] = {"winner": res.winner, "seed": int(p.get("seed", 0))}
	return CommandResult.new(CommandResult.Code.OK, {"attacker_won": attacker_won, "winner": res.winner})

# --- battle verify helper (dùng chính BattleSim -> khớp client) --------------
func _battle_score(team: Array, opponent: Array, seed_val: int, fa: String, fb: String) -> int:
	return _run(team, opponent, seed_val, fa, fb).total_damage

func _run(a_blocks: Array, b_blocks: Array, seed_val: int, fa: String, fb: String) -> SimResult:
	var a := _team(a_blocks, 0, fa)
	var b := _team(b_blocks, 1, fb)
	var sim := BattleSim.new()
	return sim.simulate(a, b, seed_val, 900)

func _team(blocks: Array, team: int, formation_id: String) -> Array:
	var out: Array = []
	for hb in blocks:
		if typeof(hb) == TYPE_DICTIONARY:
			out.append(SimCombatant.from_snapshot_hero(hb, team))
	FormationService.apply(out, Database.get_formation_def(formation_id))
	return out

# --- helpers ---------------------------------------------------------------
func _rate_ok(cmd: GameCommand) -> bool:
	var key := "%s:%s" % [cmd.player_id, str(cmd.type)]
	_rate[key] = int(_rate.get(key, 0)) + 1
	return int(_rate[key]) <= RATE_CAP

func reset_rates() -> void:
	_rate.clear()

func _checksum(blob) -> String:
	return str(JSON.stringify(blob).hash())

func _meta(entry: Dictionary) -> Dictionary:
	return {"updated_at": int(entry["updated_at"]), "play_time": int(entry["play_time"]), "version": int(entry["version"])}
