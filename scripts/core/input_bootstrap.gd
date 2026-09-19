extends Node

const BINDINGS: Dictionary = {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"run": [KEY_SHIFT],
	"jump": [KEY_H],
	"attack_primary": [KEY_Y],
	"attack_kick": [KEY_U],
	"defend": [KEY_J],
	"interact": [KEY_E]
}

func _ready() -> void:
	for action_name: String in BINDINGS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for keycode: Key in BINDINGS[action_name]:
			if _has_key(action_name, keycode):
				continue
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)

func _has_key(action_name: String, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false
