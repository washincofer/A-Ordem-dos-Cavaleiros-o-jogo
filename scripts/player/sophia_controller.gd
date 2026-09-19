extends CharacterBody2D
class_name SophiaController

signal hp_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal defense_changed(active: bool, cooldown_remaining: float)
signal action_requested(action_name: String)

enum PlayerState {
	FREE,
	DODGING,
	JUMPING,
	DEFENDING,
	STAGGERED,
	DOWN
}

@export_category("Movement")
@export var walk_speed: float = 220.0
@export var run_speed: float = 360.0
@export var stamina_max: float = 100.0
@export var run_stamina_drain_per_second: float = 25.0
@export var stamina_regen_seconds_from_zero: float = 5.0

@export_category("Jump")
@export var jump_duration: float = 0.70
@export var jump_height: float = 56.0

@export_category("Dodge")
@export var dodge_speed: float = 620.0
@export var dodge_duration: float = 0.22
@export var double_tap_window: float = 0.25

@export_category("Defense")
@export var defense_duration: float = 0.45
@export var defense_cooldown: float = 2.0
@export_range(0.0, 1.0, 0.05) var defense_damage_multiplier: float = 0.50
@export_range(0.0, 1.0, 0.05) var defense_move_multiplier: float = 0.20

@export_category("Health")
@export var hp_max: float = 100.0

@onready var visual_root: Node2D = $VisualRoot
@onready var sprite: AnimatedSprite2D = $VisualRoot/Sprite
@onready var placeholder: Polygon2D = $VisualRoot/Placeholder

var state: int = PlayerState.FREE
var hp: float
var stamina: float

var _dodge_timer: float = 0.0
var _dodge_direction: Vector2 = Vector2.ZERO
var _defense_timer: float = 0.0
var _defense_cooldown_timer: float = 0.0
var _jump_timer: float = 0.0
var _last_move_direction: Vector2 = Vector2.RIGHT
var _last_tap_time: Dictionary = {
	"move_left": -10.0,
	"move_right": -10.0,
	"move_up": -10.0,
	"move_down": -10.0
}

func _ready() -> void:
	_setup_visuals()
	hp = hp_max
	stamina = stamina_max
	_emit_status()
	_play_if_available("idle")

func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	_handle_action_inputs()
	_detect_double_tap_dodge()

	match state:
		PlayerState.DODGING:
			_process_dodge(delta)
		PlayerState.JUMPING:
			_process_jump(delta)
		PlayerState.DEFENDING:
			_process_defense()
		PlayerState.STAGGERED, PlayerState.DOWN:
			velocity = Vector2.ZERO
			move_and_slide()
		_ = delta
		_:
			_process_free_movement(delta)

	_update_animation()
	_emit_status()

func _process_free_movement(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length_squared() > 0.0:
		_last_move_direction = input_vector.normalized()

	var wants_run := Input.is_action_pressed("run") and input_vector.length_squared() > 0.0 and stamina > 0.0
	var speed := run_speed if wants_run else walk_speed
	velocity = input_vector * speed

	if wants_run:
		stamina = maxf(0.0, stamina - run_stamina_drain_per_second * delta)
	else:
		_regenerate_stamina(delta)

	if Input.is_action_just_pressed("jump"):
		_start_jump()
		return

	if Input.is_action_just_pressed("defend") and _defense_cooldown_timer <= 0.0:
		_start_defense()
		return

	move_and_slide()

func _process_jump(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * walk_speed
	move_and_slide()

	_jump_timer += delta
	var progress := clampf(_jump_timer / jump_duration, 0.0, 1.0)
	var height := sin(progress * PI) * jump_height
	visual_root.position.y = -height

	if Input.is_action_just_pressed("attack_primary"):
		action_requested.emit("jump_attack_y")
		_play_if_available("jump_attack_y")
	elif Input.is_action_just_pressed("attack_kick"):
		action_requested.emit("jump_attack_u")
		_play_if_available("jump_attack_u")

	if progress >= 1.0:
		visual_root.position.y = 0.0
		state = PlayerState.FREE

func _process_dodge(_delta: float) -> void:
	velocity = _dodge_direction * dodge_speed
	move_and_slide()
	_dodge_timer -= _delta
	if _dodge_timer <= 0.0:
		state = PlayerState.FREE

func _process_defense() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * walk_speed * defense_move_multiplier
	move_and_slide()
	if _defense_timer <= 0.0:
		state = PlayerState.FREE

func _handle_action_inputs() -> void:
	if state == PlayerState.FREE:
		if Input.is_action_just_pressed("attack_primary"):
			action_requested.emit("attack_y")
		elif Input.is_action_just_pressed("attack_kick"):
			action_requested.emit("attack_u")
		elif Input.is_action_just_pressed("interact"):
			action_requested.emit("interact")

func _detect_double_tap_dodge() -> void:
	if state != PlayerState.FREE:
		return

	var directions: Dictionary = {
		"move_left": Vector2.LEFT,
		"move_right": Vector2.RIGHT,
		"move_up": Vector2.UP,
		"move_down": Vector2.DOWN
	}
	var now := Time.get_ticks_msec() / 1000.0

	for action_name: String in directions.keys():
		if not Input.is_action_just_pressed(action_name):
			continue
		var previous: float = float(_last_tap_time[action_name])
		_last_tap_time[action_name] = now
		if now - previous <= double_tap_window:
			_start_dodge(directions[action_name])
			return

func _start_dodge(direction: Vector2) -> void:
	state = PlayerState.DODGING
	_dodge_direction = direction.normalized()
	_dodge_timer = dodge_duration
	_last_move_direction = _dodge_direction
	action_requested.emit("dodge")
	_play_if_available("dodge")

func _start_jump() -> void:
	state = PlayerState.JUMPING
	_jump_timer = 0.0
	action_requested.emit("jump")
	_play_if_available("jump")

func _start_defense() -> void:
	state = PlayerState.DEFENDING
	_defense_timer = defense_duration
	_defense_cooldown_timer = defense_cooldown
	action_requested.emit("defend")
	_play_if_available("defend")

func take_damage(amount: float, breaks_guard: bool = false) -> void:
	var final_damage := amount
	if state == PlayerState.DEFENDING and not breaks_guard:
		final_damage *= defense_damage_multiplier
	hp = maxf(0.0, hp - final_damage)
	hp_changed.emit(hp, hp_max)

	if hp <= 0.0:
		action_requested.emit("dead")
		return

	if breaks_guard:
		state = PlayerState.STAGGERED
		action_requested.emit("stagger")
		_play_if_available("stagger")
	else:
		action_requested.emit("hurt")
		_play_if_available("hurt")

func recover_from_stagger() -> void:
	if state == PlayerState.STAGGERED:
		state = PlayerState.FREE

func set_down(value: bool) -> void:
	state = PlayerState.DOWN if value else PlayerState.FREE
	_play_if_available("fall" if value else "get_up")

func _regenerate_stamina(delta: float) -> void:
	var regen_rate := stamina_max / maxf(stamina_regen_seconds_from_zero, 0.01)
	stamina = minf(stamina_max, stamina + regen_rate * delta)

func _tick_timers(delta: float) -> void:
	_defense_timer = maxf(0.0, _defense_timer - delta)
	_defense_cooldown_timer = maxf(0.0, _defense_cooldown_timer - delta)

func _update_animation() -> void:
	if state != PlayerState.FREE:
		return

	if velocity.length_squared() <= 1.0:
		_play_if_available("idle")
	elif Input.is_action_pressed("run") and stamina > 0.0:
		if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(&"run"):
			_play_if_available(&"run")
		else:
			_play_if_available(&"walk")
	else:
		_play_if_available(&"walk")

	if absf(_last_move_direction.x) > 0.05:
		sprite.flip_h = _last_move_direction.x < 0.0

func _play_if_available(animation_name: StringName) -> void:
	if sprite.sprite_frames == null:
		return
	if sprite.sprite_frames.has_animation(animation_name) and sprite.animation != animation_name:
		sprite.play(animation_name)

func _emit_status() -> void:
	hp_changed.emit(hp, hp_max)
	stamina_changed.emit(stamina, stamina_max)
	defense_changed.emit(state == PlayerState.DEFENDING, _defense_cooldown_timer)


func _setup_visuals() -> void:
	if SophiaSpriteLoader.assets_available():
		sprite.sprite_frames = SophiaSpriteLoader.build()
		placeholder.visible = false
		sprite.visible = true
	else:
		placeholder.visible = true
		sprite.visible = false
		push_warning("Sophia sprite atlases not found. Using placeholder until PNG assets are added.")
