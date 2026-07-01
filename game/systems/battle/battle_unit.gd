class_name BattleUnit
extends RefCounted
## Snapshot 1 chiến binh cho Battle Engine (KHÔNG ref Node — thuần dữ liệu, serializable).
## Dựng từ HeroInstance hoặc EnemyData; kết quả áp ngược qua source_hero_id / enemy id.

var id: String = ""
var team: int = 0                 # 0 = phe hero, 1 = phe địch
var display_name: String = ""
var max_hp: int = 1
var hp: int = 1
var attack: int = 1
var defense: int = 0
var crit_chance: float = 0.0
var crit_damage: float = 1.5
var lifesteal: float = 0.0
var attack_interval: float = 1.0  # giây giữa 2 đòn (từ speed)
var source_hero_id: String = ""   # trỏ về HeroInstance (nếu là hero) để áp hp/xp
var source_enemy_id: String = ""  # id EnemyData (nếu là quái) để loot
var xp_reward: int = 0

var cooldown: float = 0.0         # runtime trong sim

func is_alive() -> bool:
	return hp > 0

static func from_hero(h: HeroInstance, team_: int) -> BattleUnit:
	var u := BattleUnit.new()
	u.id = "h_" + h.hero_id
	u.team = team_
	u.display_name = h.display_name if h.display_name != "" else h.hero_id
	u.max_hp = h.eff_max_hp()
	u.hp = h.current_hp if h.current_hp > 0 else u.max_hp
	u.attack = h.eff_attack()
	u.defense = h.eff_defense()
	u.crit_chance = h.eff_crit_chance()
	u.crit_damage = h.eff_crit_damage()
	u.lifesteal = h.eff_lifesteal()
	u.attack_interval = clampf(100.0 / maxf(1.0, h.eff_speed()), 0.3, 3.0)
	u.source_hero_id = h.hero_id
	return u

static func from_enemy(e: EnemyData, team_: int, uid: String) -> BattleUnit:
	var u := BattleUnit.new()
	u.id = uid
	u.team = team_
	u.display_name = e.display_name
	u.max_hp = e.max_hp
	u.hp = e.max_hp
	u.attack = e.contact_damage
	u.defense = 0
	u.crit_chance = 0.0
	u.crit_damage = 1.5
	u.lifesteal = 0.0
	u.attack_interval = e.attack_interval
	u.source_enemy_id = e.id
	u.xp_reward = e.xp_reward
	return u
