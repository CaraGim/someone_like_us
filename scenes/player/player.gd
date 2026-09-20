extends CharacterBody3D

## Scoped to player-body concerns only: movement and interaction
## raycasting. Camera mode, mouse capture, and phone-panel visibility are
## each owned by the system they actually belong to (CameraRig,
## HudController) via their own GameMode.mode_changed subscriptions --
## Player does not act as a switchboard for other systems' reactions to
## game-mode changes.

@export var move_speed: float = 5.0
@export var interact_range: float = 3.0 ## Max distance from the PLAYER (not the camera) to an aimed object.
@export var aim_cast_distance: float = 50.0 ## How far the reticle ray reaches for aiming/highlighting purposes.

var speed_multiplier: float = 1.0
var focused_interactable: Node = null

@onready var camera_rig: CameraRig = $CameraRig
@onready var hud: HudController = $Hud
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

signal focused_interactable_changed(target: Node)

func _ready() -> void:
	camera_rig.target = self
	GameMode.mode_changed.connect(_on_game_mode_changed)
	_on_game_mode_changed(GameMode.current)
	focused_interactable_changed.connect(func(target: Node) -> void:
		hud.set_focused(target != null)
		var prompt_text: String = target.get_prompt() if target != null and target.has_method("get_prompt") else ""
		hud.set_prompt(prompt_text)
	)

## There's no first-person arms/body model -- hide the placeholder capsule
## rather than let the player see the inside of their own mesh.
func _on_game_mode_changed(mode: int) -> void:
	mesh_instance.visible = (mode != GameMode.Mode.QUEST_STAGE)

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
		hud.toggle_phone_in_sandbox()

	if event.is_action_pressed("interact") and not locked:
		if focused_interactable != null and focused_interactable.has_method("interact"):
			focused_interactable.interact(self)

func _physics_process(delta: float) -> void:
	_process_movement(delta)
	camera_rig.update_iso_tracking()
	_update_reticle_position()
	_update_focused_interactable()
	_update_prompt_position()

## In Sandbox mode the crosshair follows the mouse cursor; in Quest stage it
## stays fixed at true screen-center (set once by hud.center_reticle() on
## mode change), so there's nothing to update here in that mode.
func _update_reticle_position() -> void:
	if camera_rig.mode == CameraRig.Mode.ISOMETRIC:
		hud.set_reticle_screen_position(get_viewport().get_mouse_position())

## Screen point the interact raycast aims through: the mouse cursor in
## Sandbox mode, true screen-center in Quest stage.
func _get_aim_screen_point() -> Vector2:
	if camera_rig.mode == CameraRig.Mode.ISOMETRIC:
		return get_viewport().get_mouse_position()
	return get_viewport().get_visible_rect().size / 2.0

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
	var aim_point: Vector2 = _get_aim_screen_point()
	var from: Vector3 = cam.project_ray_origin(aim_point)
	var to: Vector3 = from + cam.project_ray_normal(aim_point) * aim_cast_distance
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
