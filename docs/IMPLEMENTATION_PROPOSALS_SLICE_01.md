# Propuestas de implementación - Slice 01

Este documento describe cambios concretos de código para:

1. Hacer que la inundación sea un sistema jugable.
2. Dar más peso emocional a la decisión con la civil.

Puedes implementarlos directamente en los archivos indicados.

---

## 1. Sistema de inundación jugable

### 1.1. Añadir estado de agua en `FloodedShelterController`

**Archivo:** `scripts/levels/flooded_shelter_controller.gd`

**Cambios:**

```gdscript
# Añadir nuevas variables
enum WaterLevel { LOW, MEDIUM, HIGH }

@export var initial_water_level: WaterLevel = WaterLevel.MEDIUM
@export var oxygen_drain_multiplier_high_water: float = 1.5

var water_level: WaterLevel = WaterLevel.MEDIUM
var water_rising: bool = false

signal water_level_changed(new_level: WaterLevel)

func _ready() -> void:
    water_level = initial_water_level
    # ... resto del _ready existente ...

func _on_power_activated() -> void:
    if has_power:
        return
    has_power = true
    # La energía frena o detiene la subida del agua
    water_rising = false
    if elena:
        elena.add_oxygen(oxygen_refill_on_power)
    power_restored.emit()

func _on_valve_opened() -> void:
    valves_open = min(2, valves_open + 1)
    if elena and valves_open == 1:
        elena.add_oxygen(oxygen_refill_on_valves)
    valves_progress_changed.emit(valves_open)

    if valves_open >= 2:
        # Bajar el nivel de agua cuando se abren las válvulas
        _lower_water_level()
        if flood_gate_exit:
            flood_gate_exit.open_gate()

func _lower_water_level() -> void:
    if water_level == WaterLevel.HIGH:
        water_level = WaterLevel.MEDIUM
    elif water_level == WaterLevel.MEDIUM:
        water_level = WaterLevel.LOW
    water_level_changed.emit(water_level)

func get_oxygen_drain_multiplier() -> float:
    if water_level == WaterLevel.HIGH and water_rising:
        return oxygen_drain_multiplier_high_water
    return 1.0

func start_water_rising() -> void:
    water_rising = true
```

### 1.2. Conectar el multiplicador de oxígeno en `Elena`

**Archivo:** `scripts/entities/elena.gd`

**Cambios en `_on_oxygen_timer_timeout`:**

```gdscript
func _on_oxygen_timer_timeout() -> void:
    if not is_alive:
        return

    var drain_multiplier := 1.0
    var shelter = get_tree().get_first_node_in_group("flooded_shelter")
    if shelter and shelter.has_method("get_oxygen_drain_multiplier"):
        drain_multiplier = shelter.get_oxygen_drain_multiplier()

    oxygen = max(0.0, oxygen - oxygen_drain_rate * oxygen_timer.wait_time * drain_multiplier)
    oxygen_changed.emit(oxygen)

    if oxygen <= 0.0:
        die()
```

### 1.3. Hacer que el agua suba con el tiempo (opcional)

Si quieres que el agua suba si no se actúa:

**En `FloodedShelterController`:**

```gdscript
@export var water_rise_delay_seconds: float = 30.0
var water_rise_timer: float = 0.0

func _physics_process(delta: float) -> void:
    if water_rising:
        water_rise_timer += delta
        if water_rise_timer >= water_rise_delay_seconds:
            water_rise_timer = 0.0
            _raise_water_level()

func _raise_water_level() -> void:
    if water_level == WaterLevel.LOW:
        water_level = WaterLevel.MEDIUM
    elif water_level == WaterLevel.MEDIUM:
        water_level = WaterLevel.HIGH
    water_level_changed.emit(water_level)
```

Llama a `start_water_rising()` en algún momento (por ejemplo, al entrar en la escena o tras cierto evento).

### 1.4. Feedback visual mínimo del nivel de agua

Puedes añadir un nodo de agua (un `ColorRect` o `Polygon2D` con semitransparencia) en cada sala y cambiar su posición o visibilidad según `water_level`.

Ejemplo simple en `flooded_shelter_2_5d.tscn`:

- Añadir nodos `WaterPlane` en cada sala.
- En el script del controlador, conectar `water_level_changed` y mover/ocultar esos planos.

---

## 2. Dar peso emocional a la decisión con la civil

### 2.1. Añadir una necesidad concreta de Elena

Puedes usar un flag en `FloodedShelterController` que represente:

> "Necesito salir pronto o el agua me atrapará" vs "Puedo arriesgarme a salvar a esta persona".

**En `FloodedShelterController`:**

```gdscript
var time_pressure_active: bool = false

func enable_time_pressure() -> void:
    time_pressure_active = true
    start_water_rising()
```

Y activarlo cuando, por ejemplo:
- Se abre la primera válvula.
- O cuando Elena entra en la sala de rescate.

### 2.2. Hacer que el rescate tenga un coste claro

**Opción A: coste de oxígeno**

Cuando se rescata a la civil, Elena "pierde tiempo" y el agua sube más rápido o el oxígeno drena más rápido durante un breve periodo.

En `Civilian.rescue()`:

```gdscript
func rescue() -> void:
    if not is_alive or state != State.TRAPPED:
        return
    state = State.RESCUED
    state_changed.emit(state)
    civilian_rescued.emit()
    update_visuals()

    # Coste: acelerar presión del agua
    var shelter = get_tree().get_first_node_in_group("flooded_shelter")
    if shelter and shelter.has_method("enable_time_pressure"):
        shelter.enable_time_pressure()
```

**Opción B: bloqueo temporal**

Durante unos segundos, Elena no puede moverse (animación de ayudar a levantarse, etc.). Esto se puede simular deshabilitando el input o la velocidad.

### 2.3. Reacción observable de la civil

Ya tienes `civilian_rescue_lines` en `NarrativeText`. Para usarlas:

**En `flooded_shelter_2_5d.tscn` o en un script de diálogo:**

- Conectar `civilian_rescued` a una función que muestre un pequeño cuadro de texto con una frase aleatoria.

Ejemplo mínimo en `FloodedShelterController`:

```gdscript
signal civilian_spoke(line: String)

func _on_civilian_rescued() -> void:
    civilian_rescued = true
    civilian_status_changed.emit(true)
    var line = NarrativeTextManager.get_random_civilian_rescue_line()
    civilian_spoke.emit(line)
```

Luego, en el HUD o en un nodo de diálogo, mostrar esa línea brevemente.

### 2.4. Diferencia clara en el final

Esto ya está prácticamente hecho en `NarrativeText` y `demo_end.gd`. Solo asegúrate de que:

- El texto final cambia claramente entre "Civil: Rescatada" y "Civil: No rescatada".
- Las líneas de consecuencia en `end_civilian_rescued` / `end_civilian_not_rescued` se muestran según corresponda.

---

## 3. Integración sugerida (orden de implementación)

1. **Primero:** sistema de agua en `FloodedShelterController` y conexión con oxígeno en `Elena`.
2. **Segundo:** hacer que el agua suba con el tiempo (si se decide usar).
3. **Tercero:** conectar el rescate de la civil con la presión del tiempo.
4. **Cuarto:** añadir feedback visual mínimo del nivel de agua.
5. **Quinto:** mostrar la frase de la civil al ser rescatada.

Con estos cambios, la secuencia crítica que mencionaba el crítico quedaría así:

```text
entrar en el refugio
→ comprender el peligro (agua que sube, oxígeno que baja más rápido)
→ explorar
→ ayudar a la civil (coste: más presión / menos oxígeno)
→ asumir un coste
→ observar un cambio (agua, luces, texto final)
→ proteger o perder a la civil
→ cerrar el episodio con un final distinto según la decisión
```

Si quieres, puedo preparar también un pequeño script `WaterVisuals.gd` que mueva planos de agua en cada sala según `water_level`.
