extends CharacterBody2D

@export var speed: float = 320.0
@export var acceleration: float = 2400.0
@export var friction: float = 3000.0

var nearby: Array[Area2D] = []

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 20.0
	shape.height = 80.0
	cs.shape = shape
	add_child(cs)
	var body := ColorRect.new()
	body.color = Color("00c853")
	body.size = Vector2(40.0, 80.0)
	body.position = Vector2(-20.0, -40.0)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)
	var sensor := Area2D.new()
	sensor.collision_layer = 0
	sensor.collision_mask = 4
	var sc := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 60.0
	sc.shape = circle
	sensor.add_child(sc)
	add_child(sensor)
	sensor.area_entered.connect(_on_sensor_area_entered)
	sensor.area_exited.connect(_on_sensor_area_exited)

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

func _on_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable") and not nearby.has(area):
		nearby.append(area)

func _on_sensor_area_exited(area: Area2D) -> void:
	nearby.erase(area)

func get_nearest_interactable() -> Area2D:
	var nearest: Area2D = null
	var nearest_distance := INF
	for area in nearby:
		if not is_instance_valid(area):
			continue
		var distance := global_position.distance_squared_to(area.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = area
	return nearest
