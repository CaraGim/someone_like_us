extends CanvasLayer
class_name HudController

## Owns the player's HUD primitives. Subscribes to GameMode.mode_changed
## itself to own the phone panel's visibility end-to-end (rather than Player
## computing visibility and telling this node what to show), since "is the
## phone panel visible" is fundamentally this node's own concern.

## Emitted whenever phone visibility actually changes -- e.g. for a future
## AudioManager to play the phone open/close SFX already named in
## Aduio_list.txt.
signal phone_visibility_changed(is_open: bool)

@onready var reticle: ColorRect = $Reticle
@onready var phone_panel: Control = $PhonePanel
@onready var prompt_label: Label = $PromptLabel

var _sandbox_phone_toggle: bool = false ## Only meaningful in GameMode.Mode.SANDBOX -- see toggle_phone_in_sandbox().
var _phone_visible: bool = false

func _ready() -> void:
	GameMode.mode_changed.connect(_on_game_mode_changed)
	_on_game_mode_changed(GameMode.current)

func _on_game_mode_changed(mode: int) -> void:
	# Don't let a Sandbox phone-toggle (and its InteractionLock) survive into
	# the Quest stage -- the ambient always-visible phone there doesn't need
	# it, and leaving it locked would strand world interaction for the whole
	# stage with no way to clear it (toggle_phone_in_sandbox is a no-op
	# outside Sandbox mode).
	if mode == GameMode.Mode.QUEST_STAGE and _sandbox_phone_toggle:
		_sandbox_phone_toggle = false
		InteractionLock.unlock()
	_refresh_phone_visibility(mode)
	if mode == GameMode.Mode.QUEST_STAGE:
		center_reticle()

## Phone panel visibility is DERIVED, not toggled directly: always on during
## the Quest stage (player always carries the phone, per the GDD), only on
## in Sandbox mode when the player has explicitly opened it via E/click.
func _refresh_phone_visibility(mode: int = GameMode.current) -> void:
	var should_show: bool = mode == GameMode.Mode.QUEST_STAGE or _sandbox_phone_toggle
	if should_show == _phone_visible:
		return
	_phone_visible = should_show
	phone_panel.visible = should_show
	phone_visibility_changed.emit(should_show)

## Only meaningful in Sandbox mode -- in the Quest stage the phone is always
## shown (see _refresh_phone_visibility) and this call is a no-op, since
## there's nothing to lock/unlock: the ambient Quest-stage phone view must
## never block world interaction, only actively opening/using the phone's
## functions should.
func toggle_phone_in_sandbox() -> void:
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
	_refresh_phone_visibility()

func set_focused(is_focused: bool) -> void:
	reticle.color = Color(0.2, 1.0, 0.4) if is_focused else Color(1, 1, 1, 0.6)

## Centers the reticle on screen_pos (e.g. the mouse cursor in Sandbox mode).
func set_reticle_screen_position(screen_pos: Vector2) -> void:
	reticle.position = screen_pos - reticle.size / 2.0

## Snaps the reticle back to true screen-center (Quest-stage / first-person).
func center_reticle() -> void:
	var viewport_size: Vector2 = reticle.get_viewport().get_visible_rect().size
	set_reticle_screen_position(viewport_size / 2.0)

func set_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = text != ""
	if text != "":
		prompt_label.reset_size() # so .size is correct immediately, not next idle frame

## screen_pos is the point in viewport pixels the label should hover just above.
func set_prompt_screen_position(screen_pos: Vector2) -> void:
	prompt_label.position = Vector2(
		screen_pos.x - prompt_label.size.x / 2.0,
		screen_pos.y - prompt_label.size.y - 12.0
	)
