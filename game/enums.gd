class_name Enums
extends Object
## Enum toàn cục dùng chung (P3). Truy cập: Enums.ClassRole.TANK, Enums.Rarity.MYTHIC...
## Data-driven def lưu bằng int enum để .tres/JSON gọn + đồng bộ với docs (HERO/EQUIPMENT/RUNE).

enum ClassRole { TANK, WARRIOR, ASSASSIN, RANGER, MAGE, SUPPORT, SUMMONER }
enum Race { HUMAN, ELF, ORC, DWARF, UNDEAD, ANGEL, DEMON, DRAGONKIN }
enum Element { FIRE, ICE, WIND, EARTH, LIGHTNING, HOLY, DARK, POISON, ARCANE, VOID }
enum Rarity { COMMON, ELITE, EPIC, LEGEND, MYTHIC }
enum EquipSlot { WEAPON, HELMET, ARMOR, GLOVES, BOOTS, RING, NECKLACE, ARTIFACT }
enum WeaponType { SWORD, SHIELD, SPEAR, DAGGER, DUAL_BLADE, BOW, CROSSBOW, GUN, STAFF, ORB, WAND }
enum RuneCategory { OFFENSIVE, DEFENSIVE, UTILITY, CONTROL, SUMMONER }
enum SkillKind { PASSIVE, ACTIVE, ULTIMATE }
enum SkillType { DAMAGE, HEAL, SHIELD, BUFF, DEBUFF, CC, SUMMON, UTILITY }

# --- P4: combat SIM / boss / arena ---
## Cách chọn mục tiêu của 1 skill trong BattleSim (data-driven, không hardcode).
enum SkillTarget { SINGLE_LOWEST_HP, ALL_ENEMIES, SELF, LOWEST_HP_ALLY, RANDOM_ENEMY, HIGHEST_THREAT }
## Quy tắc boss chọn skill nào để cast (BOSS.md / COMBAT.md).
enum SkillSelectRule { LOWEST_CD, HIGHEST_THREAT, ON_CLUSTER, PHASE_FIXED }
## Hiệu ứng khống chế cứng — STUN có thể ngắt cast (interrupt).
enum CcType { NONE, STUN }
## Ngưỡng kích hoạt chuyển phase boss.
enum BossTrigger { HP_PCT, TIME_ELAPSED, MINION_COUNT, BREAK_FULL }
enum BossType { MINI, REGION, DUNGEON, WORLD, EVENT, STORY }
enum Difficulty { NORMAL, HARD, NIGHTMARE, HELL, MYTHIC, CHAOS }
## Máy trạng thái sự kiện World Boss.
enum BossEventState { ANNOUNCED, ACTIVE, WON, FAILED, COOLDOWN }
## Kết quả 1 trận Đấu Trường (timeout xử theo HP còn lại).
enum ArenaOutcome { WIN, LOSE, TIMEOUT_WIN, TIMEOUT_LOSE }

# --- P5: story / season / event ---
## Vòng đời event (build-events): Scheduled→Preparation→Active→Reward→Cooldown→Done.
enum EventPhase { SCHEDULED, PREPARATION, ACTIVE, REWARD, COOLDOWN, DONE }

const EQUIP_SLOT_COUNT := 8
const RARITY_NAMES := ["Common", "Elite", "Epic", "Legend", "Mythic"]
const CLASS_NAMES := ["Tank", "Warrior", "Assassin", "Ranger", "Mage", "Support", "Summoner"]
const RACE_NAMES := ["Human", "Elf", "Orc", "Dwarf", "Undead", "Angel", "Demon", "Dragonkin"]

## Số dòng affix phụ theo rarity (EQUIPMENT.md).
static func secondary_affix_count(rarity: int) -> int:
	match rarity:
		Rarity.COMMON: return 1
		Rarity.ELITE: return 2
		Rarity.EPIC: return 3
		Rarity.LEGEND: return 4
		Rarity.MYTHIC: return 4
		_: return 1
