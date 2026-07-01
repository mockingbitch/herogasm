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
