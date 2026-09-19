extends Node3D
class_name CameraRig

## Owns both of the player's camera behaviors, one per game mode (see
## autoload GameMode) -- there is no third "chase camera" mode.
## Isometric = Sandbox mode (default, includes the basement): fixed-pitch
## camera that orbits `target`'s position at a fixed distance via mouse
## wheel (Don't Starve Together-style). FirstPerson = Quest stage: eye-level
## mouse-look camera.

enum Mode { ISOMETRIC, FIRST_PERSON }

@export var mouse_sensitivity: float = 0.0025
@export var pitch_min_deg: float = -40.0
@export var pitch_max_deg: float = 70.0
@export var iso_pitch_deg: float = 45.0
@export var iso_distance: float = 10.0
@export var iso_rotation_step_deg: float = 15.0
@export var iso_look_at_height_offset: float = 2.357 ## Raises the look-at point above the player so the player renders 1/3 up from the bottom of the screen (aim reticle stays at true center) -- otherwise the reticle ray always aims straight at the player's own body.

var mode: int = Mode.ISOMETRIC
var iso_yaw_deg: float = 0.0
var target: Node3D

@onready var first_person_pivot: Node3D = $FirstPersonPivot
@onready var first_person_camera: Camera3D = $FirstPersonPivot/FirstPersonCamera
@onready var iso_rig: Node3D = $IsoRig
@onready var iso_camera: Camera3D = $IsoRig/IsoCamera

func set_mode(new_mode: int) -> void:
	mode = new_mode
	first_person_camera.current = (mode == Mode.FIRST_PERSON)
	iso_camera.current = (mode == Mode.ISOMETRIC)
	if mode == Mode.ISOMETRIC:
		update_iso_tracking()

func apply_mouse_look(relative: Vector2) -> void:
	if mode != Mode.FIRST_PERSON:
		return
	first_person_pivot.rotate_y(-relative.x * mouse_sensitivity)
	var pitch: float = first_person_camera.rotation.x - relative.y * mouse_sensitivity
	first_person_camera.rotation.x = clamp(pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))

func apply_rotation_step(direction: int) -> void:
	if mode != Mode.ISOMETRIC:
		return
	iso_yaw_deg += direction * iso_rotation_step_deg

func update_iso_tracking() -> void:
	if mode != Mode.ISOMETRIC or target == null:
		return
	var yaw: float = deg_to_rad(iso_yaw_deg)
	var pitch: float = deg_to_rad(iso_pitch_deg)
	var look_at_point: Vector3 = target.global_position + Vector3(0, iso_look_at_height_offset, 0)
	var offset: Vector3 = Vector3(0, 0, iso_distance).rotated(Vector3.RIGHT, -pitch).rotated(Vector3.UP, yaw)
	iso_rig.global_position = look_at_point + offset
	iso_rig.look_at(look_at_point, Vector3.UP)

func get_active_camera() -> Camera3D:
	return first_person_camera if mode == Mode.FIRST_PERSON else iso_camera
