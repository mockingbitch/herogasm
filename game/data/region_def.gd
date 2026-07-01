class_name RegionDef
extends Resource
## Vùng thế giới (data-driven). Chứa danh sách zone; gate theo roster level.

@export var id: String = ""
@export var display_name: String = ""
@export var theme: String = "plains"          # plains/forest/mountain (lighting/music sau)
@export var zone_ids: Array[String] = []
@export var required_level: int = 1           # roster_max_level >= mức này để mở region
