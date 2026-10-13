extends CharacterBody2D

signal stamina_changed(value: float, maximum: float)
signal dash_started

@export var speed: float = 320.0
@export var acceleration: float = 2400.0
@export var friction: float = 3000.0
@export var max_stamina: float = 100.0
@export var move_drain_per_second: float = 6.0
@export var idle_recover_per_second: float = 12.0
@export var dash_cost: float = 25.0
@export var dash_speed: float = 640.0
@export var dash_duration: float = 0.28

var nearby: Array = []
var stamina: float = 100.0
var dash_time_left: float = 0.0

func _ready() -> void:
	add_to_group("player")
	var cs := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 20.0
	shape.height = 80.0
	cs.shape = shape
	add_child(cs)
	var body := ColorRect.new()
	body.color = Color("00c853")
	body.size = Vector2(40, 80)
	body.position = Vector2(-20, -40)
	add_child(body)
	var sensor := Area2D.new()
	var sc := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 60.0
	sc.shape = circle
	sensor.add_child(sc)
	add_child(sensor)
	sensor.area_entered.connect(func(a): if not nearby.has(a): nearby.append(a))
	sensor.area_exited.connect(func(a): nearby.erase(a))
	stamina_changed.emit(stamina, max_stamina)

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dash_time_left > 0.0:
		dash_time_left -= delta
		if dash_time_left <= 0.0:
			collision_mask = 1
			velocity = velocity.limit_length(speed)
	elif dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		drain_stamina(move_drain_per_second * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		recover_stamina(idle_recover_per_second * delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()
	elif event.is_action_pressed("dodge"):
		try_dash()

func try_dash() -> bool:
	if dash_time_left > 0.0 or stamina < dash_cost:
		return false
	var direction := velocity
	if direction.length() < 1.0:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() < 1.0:
		direction = Vector2.RIGHT
	drain_stamina(dash_cost)
	velocity = direction.normalized() * dash_speed
	dash_time_left = dash_duration
	collision_mask = 0
	dash_started.emit()
	return true

func drain_stamina(amount: float) -> void:
	set_stamina(stamina - amount)

func recover_stamina(amount: float) -> void:
	set_stamina(stamina + amount)

func set_stamina(value: float) -> void:
	var next := clampf(value, 0.0, max_stamina)
	if not is_equal_approx(next, stamina):
		stamina = next
		stamina_changed.emit(stamina, max_stamina)

func try_interact() -> bool:
	if nearby.is_empty():
		return false
	nearby[0].call("interact")
	return true
