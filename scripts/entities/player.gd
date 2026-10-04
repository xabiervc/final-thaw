extends CharacterBody2D

@export var speed: float = 320.0
@export var acceleration: float = 2400.0
@export var friction: float = 3000.0

var nearby: Array = []

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

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()

func try_interact() -> bool:
	if nearby.is_empty():
		return false
	nearby[0].call("interact")
	return true
