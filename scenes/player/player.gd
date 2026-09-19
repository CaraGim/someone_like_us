extends CharacterBody3D

@export var move_speed: float = 5.0
@export var interact_range: float = 3.0 ## Max distance from the PLAYER (not the camera) to an aimed object.
@export var aim_cast_distance: float = 50.0 ## How far the reticle ray reaches for aiming/highlighting purposes.

var speed_multiplier: float = 1.0
var focused_interactable: Node = null
var _sandbox_phone_toggle: bool = false ## Only meaningful in GameMode.Mode.SANDBOX -- see _toggle_phone_in_sandbox().

@onready var camera_rig: CameraRig = $CameraRig
@onready var hud: HudController = $Hud

signal focused_interactable_changed(target: Node)
signal phone_toggled(is_open: bool)

func _ready() -> void:
	camera_rig.target = self
	GameMode.mode_changed.connect(_on_game_mode_changed)
	_on_game_mode_changed(GameMode.current)
	focused_interactable_changed.connect(func(target: Node) -> void:
		hud.set_focused(target != null)
		var prompt_text: String = target.get_prompt() if target != null and target.has_method("get_prompt") else ""
		hud.set_prompt(prompt_text)
	)
	phone_toggled.connect(hud.set_phone_open)
	_update_mouse_capture()

func _on_game_mode_changed(mode: int) -> void:
	camera_rig.set_mode(CameraRig.Mode.FIRST_PERSON if mode == GameMode.Mode.QUEST_STAGE else CameraRig.Mode.ISOMETRIC)
	_refresh_phone_visibility()

## Phone panel visibility is DERIVED, not toggled directly: always on during
## the Quest stage (player always carries the phone, per the GDD), only on
## in Sandbox mode when the player has explicitly opened it via E/click.
func _refresh_phone_visibility() -> void:
	var should_show: bool = GameMode.current == GameMode.Mode.QUEST_STAGE or _sandbox_phone_toggle
	phone_toggled.emit(should_show)

func _unhandled_input(event: InputEvent) -> void:
	var locked: bool = InteractionLock.is_locked()

	if event is InputEventMouseMotion and not locked:
		camera_rig.apply_mouse_look(event.relative)

	if not locked:
		if event.is_action_pressed("camera_rotate_ccw"):
			camera_rig.apply_rotation_step(-1)
		if event.is_action_pressed("camera_rotate_cw"):
			camera_rig.apply_rotation_step(1)

	if event.is_action_pressed("toggle_phone"):
		_toggle_phone_in_sandbox()

	if event.is_action_pressed("interact") and not locked:
		if focused_interactable != null and focused_interactable.has_method("interact"):
			focused_interactable.interact(self)

	# TODO: temporary debug key only (bound to the C key, see input_setup.gd).
	# Delete this handler once a real quest stage exists to call
	# GameMode.set_mode() itself on stage enter/exit.
	if event.is_action_pressed("debug_toggle_game_mode") and not locked:
		var next_mode: int = GameMode.Mode.QUEST_STAGE if GameMode.current == GameMode.Mode.SANDBOX else GameMode.Mode.SANDBOX
		GameMode.set_mode(next_mode)

func _physics_process(delta: float) -> void:
	_process_movement(delta)
	camera_rig.update_iso_tracking()
	_update_focused_interactable()
	_update_prompt_position()

func _process_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_back")

	var cam: Camera3D = camera_rig.get_active_camera()
	var cam_basis: Basis = cam.global_transform.basis if cam else global_transform.basis
	var forward: Vector3 = -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right: Vector3 = cam_basis.x
	right.y = 0.0
	right = right.normalized()

	var direction: Vector3 = (forward * -input_dir.y + right * input_dir.x)
	if direction.length_squared() > 0.0:
		direction = direction.normalized()

	var target_speed: float = move_speed * speed_multiplier
	velocity.x = direction.x * target_speed
	velocity.z = direction.z * target_speed

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	move_and_slide()

func _update_focused_interactable() -> void:
	var cam: Camera3D = camera_rig.get_active_camera()
	if cam == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var screen_center: Vector2 = viewport_size / 2.0
	var from: Vector3 = cam.project_ray_origin(screen_center)
	var to: Vector3 = from + cam.project_ray_normal(screen_center) * aim_cast_distance
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [get_rid()] # never let the player's own body block their own aim ray
	var result: Dictionary = space_state.intersect_ray(query)

	var new_focus: Node = null
	if result and result.has("collider"):
		var collider = result["collider"]
		var hit_position: Vector3 = result["position"]
		var within_reach: bool = global_position.distance_to(hit_position) <= interact_range
		if collider.has_method("interact") and within_reach:
			new_focus = collider

	if new_focus != focused_interactable:
		focused_interactable = new_focus
		focused_interactable_changed.emit(focused_interactable)

func _update_prompt_position() -> void:
	if focused_interactable == null or not focused_interactable.has_method("get_label_position"):
		return
	var cam: Camera3D = camera_rig.get_active_camera()
	if cam == null:
		return
	var world_pos: Vector3 = focused_interactable.get_label_position()
	if cam.is_position_behind(world_pos):
		return
	hud.set_prompt_screen_position(cam.unproject_position(world_pos))

## Only meaningful in Sandbox mode -- in the Quest stage the phone is always
## shown (see _refresh_phone_visibility) and this toggle has no effect,
## since there's nothing to lock/unlock: the ambient Quest-stage phone view
## must never block world interaction, only actively opening/using the
## phone's functions should (see the note on InteractionLock below).
func _toggle_phone_in_sandbox() -> void:
	if GameMode.current != GameMode.Mode.SANDBOX:
		return
	_sandbox_phone_toggle = not _sandbox_phone_toggle
	# NOTE: this is our current stand-in for "actively using the phone" --
	# once real interactive phone-app screens exist, locking should move to
	# "which app screen is open" rather than "is the panel visible".
	if _sandbox_phone_toggle:
		InteractionLock.lock()
	else:
		InteractionLock.unlock()
	_update_mouse_capture()
	_refresh_phone_visibility()

func _update_mouse_capture() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _sandbox_phone_toggle else Input.MOUSE_MODE_CAPTURED
