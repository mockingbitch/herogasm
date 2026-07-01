class_name SimCombatant
extends RefCounted
## Chiến binh trong BattleSim (P4) — giàu hơn BattleUnit: skill, status, shield, formation slot,
## cờ boss. THUẦN dữ liệu (serializable, KHÔNG ref Node) -> tất định + replay + PvP snapshot.
## Dựng từ HeroInstance / EnemyData / BossDef. BattleEngine (P1) vẫn dùng BattleUnit riêng.

var id: String = ""
var team: int = 0                     # 0 = phe người chơi, 1 = phe địch/boss
var display_name: String = ""
var max_hp: int = 1
var hp: int = 1
var attack: int = 1
var defense: int = 0
var crit_chance: float = 0.0
var crit_damage: float = 1.5
var lifesteal: float = 0.0
var resist: float = 0.0               # giảm % damage SAU def (0..0.9) — pipeline COMBAT.md
var attack_interval: float = 1.0      # nhịp basic-attack (từ speed)

var is_boss: bool = false
var is_minion: bool = false
var source_hero_id: String = ""       # trỏ HeroInstance (áp hp/contribution)
var source_enemy_id: String = ""      # id EnemyData (loot)
var slot: int = -1                    # ô đội hình (FormationDef.slots index)
var row: int = 0                      # 0 = front, 1 = back (buff vị trí)

# --- runtime status ---
var shield: int = 0                   # hấp thụ trước HP
var stun_until: int = -1              # tick <= giá trị này => bị stun
var stun_immune: bool = false         # enrage boss miễn stun (BOSS.md)
var dmg_taken_mult: float = 1.0       # >1 khi boss bị break-stun (nhận nhiều damage hơn)
var skills: Array[SkillRuntime] = []  # skills[0] luôn là basic-attack
var casting_skill: SkillRuntime = null
var cast_remaining: float = 0.0
var cast_target_id: String = ""
var warned: bool = false              # đã phát banner warning cho cast hiện tại

# --- boss (chỉ set khi is_boss) ---
var boss_state = null                 # BossRuntimeState
var boss_def: BossDef = null
var boss_phases: Array = []           # Array[BossPhaseDef] theo phase_ids
var base_stats: Dictionary = {}       # snapshot base (attack/defense/attack_interval) để phase mult tính theo base

func is_alive() -> bool:
	return hp > 0

func hp_pct_of() -> float:
	return float(hp) / float(maxi(1, max_hp))

func is_stunned(tick: int) -> bool:
	return tick <= stun_until

func is_casting() -> bool:
	return casting_skill != null

func add_skill(def: SkillDef) -> void:
	skills.append(SkillRuntime.new(def))

func clear_cast() -> void:
	casting_skill = null
	cast_remaining = 0.0
	cast_target_id = ""
	warned = false

## Reset trạng thái combat GIỮA các wave stage (giữ HP, xoá cd/stun/shield/cast).
func reset_combat_state() -> void:
	shield = 0
	stun_until = -1
	clear_cast()
	for sk in skills:
		sk.cooldown = 0.0

## Dựng combatant cho hero (chỉ số qua FinalStats + effective_power, khớp BattleUnit.from_hero).
static func from_hero(h: HeroInstance, team_: int) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = "h_" + h.hero_id
	c.team = team_
	c.display_name = h.display_name if h.display_name != "" else h.hero_id
	var fs: FinalStats = h.get_final_stats(h.team_context)
	var ep := h.effective_power()
	c.max_hp = maxi(1, int(round(fs.get_v("bonus_max_hp", 1.0))))
	c.hp = h.current_hp if h.current_hp > 0 else c.max_hp
	c.attack = maxi(1, int(round(fs.get_v("bonus_attack") * ep)))
	c.defense = int(round(fs.get_v("bonus_defense")))
	c.crit_chance = fs.get_v("crit_chance")
	c.crit_damage = fs.get_v("crit_damage", 1.5)
	c.lifesteal = fs.get_v("lifesteal")
	c.attack_interval = clampf(100.0 / maxf(1.0, fs.get_v("bonus_speed", 92.0)), 0.3, 3.0)
	c.source_hero_id = h.hero_id
	c.add_skill(SkillFactory.basic_attack(c.attack_interval))
	return c

static func from_enemy(e: EnemyData, team_: int, uid: String) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = uid
	c.team = team_
	c.display_name = e.display_name
	c.max_hp = e.max_hp
	c.hp = e.max_hp
	c.attack = e.contact_damage
	c.attack_interval = e.attack_interval
	c.source_enemy_id = e.id
	c.add_skill(SkillFactory.basic_attack(c.attack_interval))
	return c

## Dựng combatant từ ArenaSnapshot per-hero block (stat đã freeze -> tất định qua thời gian).
static func from_snapshot_hero(hb: Dictionary, team_: int) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = "s%d_%s" % [team_, str(hb.get("hero_id", ""))]
	c.team = team_
	c.display_name = str(hb.get("name", hb.get("hero_id", "")))
	c.max_hp = maxi(1, int(hb.get("max_hp", 1)))
	c.hp = c.max_hp
	c.attack = maxi(1, int(hb.get("attack", 1)))
	c.defense = int(hb.get("defense", 0))
	c.crit_chance = float(hb.get("crit_chance", 0.0))
	c.crit_damage = float(hb.get("crit_damage", 1.5))
	c.lifesteal = float(hb.get("lifesteal", 0.0))
	c.attack_interval = clampf(float(hb.get("attack_interval", 1.0)), 0.3, 3.0)
	c.add_skill(SkillFactory.basic_attack(c.attack_interval))
	return c
