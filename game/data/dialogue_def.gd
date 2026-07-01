class_name DialogueDef
extends Resource
## Dialogue/Cutscene nhẹ (data-driven). SIM (state) tách VIEW (DialogueRunner đọc def này).
## lines cho hội thoại; slides cho cutscene (pixel slide + text). next_action: unlock/start_battle/none.

@export var id: StringName = &""
@export var lines: Array = []           # [{speaker, portrait_id, text}]
@export var slides: Array = []          # [{image_id, text}] (cutscene)
@export var next_action: Dictionary = {}  # {type:"unlock"/"start_battle"/"none", ...}

func line_count() -> int:
	return lines.size()

func is_cutscene() -> bool:
	return not slides.is_empty()
