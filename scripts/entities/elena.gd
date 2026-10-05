extends CharacterBody2D
class_name Elena

@export var move_speed: float = 220.0
@export var air_drag: float = 0.92
@export var ground_drag: float = 0.82
@export var gravity: float = 980.0
@export var jump_velocity: float = -340.0

@export var oxygen_max: float = 100.0
@export var oxygen_drain_rate: float = 2.5

var oxygen: float = 100.0
var is_alive: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var oxygen_timer: Timer = $OxygenTimer

var interactable_nearby: Interactable = null

signal oxygen_changed(new_oxygen: float)
signal player_died

func _ready() -> void:
	oxygen = oxygen_max
	oxygen_timer.wait_time = 0.1
	oxygen_timer.timeout.connect(_on_oxygen_timer_timeout)
	oxygen_timer.start()

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		velocity.x = input_dir * move_speed
		sprite.flip_h = input_dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * ground_drag)

	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.x *= air_drag

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

func _on_oxygen_timer_timeout() -> void:
	if not is_alive:
		return

	oxygen = max(0.0, oxygen - oxygen_drain_rate * oxygen_timer.wait_time)
	oxygen_changed.emit(oxygen)

	if oxygen <= 0.0:
		die()

func die() -> void:
	is_alive = false
	player_died.emit()

func can_interact() -> bool:
	return is_alive and interactable_nearby != null

func try_interact() -> bool:
	if not can_interact():
		return false
	interactable_nearby.interact(self)
	return true

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Interactable:
		interactable_nearby = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == interactable_nearby:
		interactable_nearby = null

func add_oxygen(amount: float) -> void:
	if not is_alive:
		return
	oxygen = min(oxygen_max, oxygen + amount)
	oxygen_changed.emit(oxygen)
