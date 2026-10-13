extends Area2D
## Estación que recupera resistencia mientras el jugador permanece dentro.

@export var recover_per_second: float = 30.0
@export var tint: Color = Color(0.25, 0.85, 1.0, 0.22)

var _players: Array = []

func _ready() -> void:
	monitoring = true
	var visual := ColorRect.new()
	visual.color = tint
	visual.size = Vector2(180, 180)
	visual.position = Vector2(-90, -90)
	add_child(visual)
	var core := ColorRect.new()
	core.color = Color(0.25, 0.85, 1.0)
	core.size = Vector2(28, 28)
	core.position = Vector2(-14, -14)
	add_child(core)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 90.0
	shape.shape = circle
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
			player.recover_stamina(recover_per_second * delta)
		else:
			_players.erase(player)
