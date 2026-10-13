extends Area2D
## Zona que drena resistencia mientras el jugador permanece dentro.

@export var drain_per_second: float = 12.0
@export var tint: Color = Color(1.0, 0.45, 0.2, 0.18)

var _players: Array = []

func _ready() -> void:
	monitoring = true
	var visual := ColorRect.new()
	visual.color = tint
	visual.size = Vector2(360, 240)
	visual.position = Vector2(-180, -120)
	add_child(visual)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(360, 240)
	shape.shape = rectangle
	add_child(shape)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	var player := area.get_parent()
	if player != null and player.is_in_group("player") and not _players.has(player):
		_players.append(player)

func _on_area_exited(area: Area2D) -> void:
	var player := area.get_parent()
	if player != null:
		_players.erase(player)

func _process(delta: float) -> void:
	for player in _players.duplicate():
		if is_instance_valid(player):
			player.drain_stamina(drain_per_second * delta)
		else:
			_players.erase(player)
