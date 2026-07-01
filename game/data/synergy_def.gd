class_name SynergyDef
extends Resource
## Aura team theo count race/class (HERO.md Synergy). Áp percent cho MỌI hero trong team.

@export var id: String = ""
@export var kind: String = "race"                    # "race" | "class"
@export var key: String = ""                         # khớp hero.race / hero.class_role
@export var thresholds: Dictionary = {}              # {2:{stat:pct}, 3:{...}, 4:{...}}
