extends Node

func _ready() -> void:
	_define_action("move_forward", [_key(KEY_W)])
	_define_action("move_back", [_key(KEY_S)])
	_define_action("move_left", [_key(KEY_A)])
	_define_action("move_right", [_key(KEY_D)])
	_define_action("interact", [_key(KEY_F), _mouse(MOUSE_BUTTON_LEFT)])
	_define_action("toggle_phone", [_key(KEY_E)])
	_define_action("camera_rotate_ccw", [_mouse(MOUSE_BUTTON_WHEEL_UP)])
	_define_action("camera_rotate_cw", [_mouse(MOUSE_BUTTON_WHEEL_DOWN)])

func _define_action(action_name: String, events: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in events:
		InputMap.action_add_event(action_name, event)

func _key(physical_keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	return event

func _mouse(button_index: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	return event
