extends "res://scripts/components/interactable.gd"

@export var fragment_id: String = ""
@export var memory_text: String = ""

var collected: bool = false
var blocked_check: Callable = Callable()
var _gem: MeshInstance3D = null
var _glow: OmniLight3D = null
var _t: float = 0.0

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Recoger fragmento"
	if display_name.is_empty():
		display_name = "Fragmento de memoria"
	_gem = B.box(self, Vector3(0.3, 0.3, 0.3), Vector3(0.0, 1.0, 0.0), Color(0.3, 0.9, 1.0), 3.0)
	_gem.rotation_degrees = Vector3(45.0, 0.0, 45.0)
	_glow = OmniLight3D.new()
	_glow.light_color = Color(0.3, 0.9, 1.0)
	_glow.light_energy = 0.6
	_glow.omni_range = 3.0
	_glow.position = Vector3(0.0, 1.0, 0.0)
	add_child(_glow)

func _process(delta: float) -> void:
	if collected:
		return
	_t += delta
	_gem.position.y = 1.0 + 0.1 * sin(_t * 2.0)
	_gem.rotation_degrees.y += 40.0 * delta

func _on_interact(_actor: Node3D) -> void:
	if collected:
		return
	if blocked_check.is_valid() and bool(blocked_check.call()):
		show_message("El brazo robótico bloquea el acceso al fragmento.", 4.0)
		return
	_collect()
	if not memory_text.is_empty():
		show_message(memory_text, 9.0)

func _collect() -> void:
	collected = true
	enabled = false
	_gem.visible = false
	_glow.visible = false
	if not GameManager.memory_fragments_collected.has(fragment_id):
		GameManager.memory_fragments_collected.append(fragment_id)
	GameManager.stats_changed.emit()

func get_state() -> Dictionary:
	return {"collected": collected}

func apply_state(state: Dictionary) -> void:
	if bool(state.get("collected", false)):
		_collect()
