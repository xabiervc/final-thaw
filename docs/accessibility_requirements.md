# FINAL THAW — Accessibility Requirements (Testable, Not Optional)

## Propósito

Este documento define requisitos de accesibilidad **COMPROBABLES**, no solo "opciones en menú." Cada requisito debe poder verificarse con test objetivo (pass/fail). Si no se puede testear, no es un requisito válido.

---

## 1. Tamaño Mínimo y Escalado de Texto

### Requisito
- **Tamaño base**: 16px a 100% escala (legible a 3 metros en 1080p)
- **Rango de escalado**: 75%, 100%, 125%, 150%, 175%, 200%
- **A 200%**: Todo texto UI debe ser 32px mínimo

### Cómo Testear
```
[PASS] Texto de menú principal mide 16px ±1px a 100% escala (usar Godot Debugger, medir píxeles)
[PASS] Texto escala proporcionalmente: 100% = 16px, 200% = 32px (no 30px, no 34px)
[PASS] Texto a 200% no se sale de contenedores UI (botones, paneles, labels)
[PASS] Texto a 75% sigue siendo legible (no <12px)
[FAIL] Texto se pixela al escalar (debe usar font rendering apropiado)
[FAIL] Texto se corta en contenedores a 150%+ escala
```

### Implementación Técnica
```gdscript
# En todos los Label nodes
font_size = base_font_size * (ui_scale / 100.0)
rect_min_size = Vector2(0, font_size * 1.5)  # Espacio para altura de línea
```

---

## 2. Contraste y Modos de Color

### Requisito
- **Contraste mínimo**: 4.5:1 para texto normal, 3:1 para texto grande (>24px)
- **Modo alto contraste**: Fondo negro (#000000), texto blanco (#FFFFFF) o amarillo (#FFFF00)
- **Modos daltonismo**: 12 tipos (deuteranopia, protanopia, tritanopia, monocromacia, etc.)

### Cómo Testear
```
[PASS] Texto negro (#000000) sobre blanco (#FFFFFF) = 21:1 contraste (medir con herramienta de contraste)
[PASS] Texto blanco (#FFFFFF) sobre negro (#000000) = 21:1 contraste
[PASS] Texto amarillo (#FFFF00) sobre negro (#000000) = 19.5:1 contraste
[PASS] Modo deuteranopia: rojo y verde son distinguibles sin depender solo de color (usar patrones: rojo = líneas diagonales, verde = líneas horizontales)
[PASS] Modo monocromacia: toda UI usa solo valor (brillo), no hue. Medir con herramienta de desaturación.
[FAIL] Texto gris (#808080) sobre negro (#000000) = 1.9:1 contraste (ilegible)
[FAIL] Información crítica transmitida solo por color (ej: "rojo = peligro" sin icono o patrón)
```

### Herramientas de Verificación
- **WebAIM Contrast Checker**: https://webaim.org/resources/contrastchecker/
- **Godot Plugin**: "Accessibility Tools" (disponible en Asset Library)
- **Manual**: Desaturar screenshot a grayscale, verificar que información sigue siendo legible

---

## 3. Subtítulos Configurables

### Requisito
- **Tamaño**: Pequeño (14px), Mediano (18px), Grande (24px), Extra Grande (32px)
- **Color de texto**: Blanco, Amarillo, Cian, Magenta (selector)
- **Fondo**: Ninguno, Semi-transparente negro (#80000000), Sólido negro (#FF000000)
- **Borde de texto**: Ninguno, Negro, Blanco (para contraste con fondo variable)

### Cómo Testear
```
[PASS] Subtítulos en tamaño Extra Grande (32px) son legibles desde 3 metros en 1080p
[PASS] Subtítulos en color Magenta (#FF00FF) sobre fondo blanco con borde negro son distinguibles
[PASS] Subtítulos con fondo sólido negro no muestran "ghosting" en escenas oscuras
[PASS] Subtítulos sin fondo en escena clara (nieve, cielo) son legibles (texto blanco con borde negro)
[FAIL] Subtítulos hardcoded en blanco sin opciones de color/fondo
[FAIL] Subtítulos se superponen con UI (HUD, menús) sin opción de reposicionar
```

### Implementación Técnica
```gdscript
# En subtitle_label.gd
@export var subtitle_size: int = 18  # 14, 18, 24, 32
@export var subtitle_color: Color = Color.WHITE
@export var subtitle_background: int = 1  # 0=none, 1=semi, 2=solid
@export var subtitle_border: Color = Color.BLACK

func _ready():
    add_theme_font_size_override("font_size", subtitle_size)
    add_theme_color_override("font_color", subtitle_color)
    if subtitle_background == 1:
        self.get("custom_styles/normal").bg_color = Color(0, 0, 0, 0.5)
    elif subtitle_background == 2:
        self.get("custom_styles/normal").bg_color = Color(0, 0, 0, 1.0)
    add_theme_color_override("font_outline_color", subtitle_border)
    add_theme_constant_override("outline_size", 2 if subtitle_border.a > 0 else 0)
```

---

## 4. Identificación de Hablantes

### Requisito
- **Etiquetas de hablante**: Siempre visibles (no opcionales)
- **Color por personaje**: Elena = Cian (#00FFFF), Marcus = Naranja (#FFA500), Voss = Púrpura (#800080), NPCs = Blanco (#FFFFFF)
- **Formato**: "[Nombre]: Diálogo" (ej: "[Elena]: Keep moving.")

### Cómo Testear
```
[PASS] Subtítulo muestra "[Elena]: Keep moving." con texto en cian (#00FFFF)
[PASS] Subtítulo muestra "[Marcus]: I've got your back." con texto en naranja (#FFA500)
[PASS] Subtítulo muestra "[Voss]: Every world is built on corpses." con texto en púrpura (#800080)
[PASS] NPC sin nombre muestra "[???]: Who's there?" o "[Guard]: Halt!"
[FAIL] Subtítulo solo muestra diálogo sin hablante: "Keep moving."
[FAIL] Todos los hablantes usan mismo color (blanco)
```

### Implementación Técnica
```gdscript
# En dialogue_system.gd
var speaker_colors = {
    "Elena": Color(0, 1, 1),      # Cian
    "Marcus": Color(1, 0.65, 0),  # Naranja
    "Voss": Color(0.5, 0, 0.5),   # Púrpura
    "default": Color(1, 1, 1)     # Blanco
}

func show_subtitle(speaker: String, text: String):
    var color = speaker_colors.get(speaker, speaker_colors["default"])
    subtitle_label.text = "[%s]: %s" % [speaker, text]
    subtitle_label.add_theme_color_override("font_color", color)
```

---

## 5. Indicadores Visuales y Auditivos Redundantes

### Requisito
- **Cada sonido importante** debe tener indicador visual
- **Cada señal visual** debe tener indicador auditivo (opcional si es decorativa)
- **Direccionalidad**: Indicador visual debe mostrar dirección (izquierda/derecha/arriba/abajo)

### Cómo Testear
```
[PASS] Enemigo ataca por izquierda: sonido 3D + flecha UI en borde izquierdo de pantalla
[PASS] Hazard erupta: sonido de erupción + partículas visibles + icono de advertencia en HUD
[PASS] NPC habla: voz + subtítulo + icono de "hablando" sobre cabeza de NPC
[PASS] Item coleccionable: brillo visual + chime auditivo + icono en minimap
[FAIL] Enemigo ataca solo con sonido (sin indicador visual para sordos)
[FAIL] Hazard solo con partículas (sin sonido para ciegos)
[FAIL] Item solo con brillo (sin sonido, jugador ciego no lo encuentra)
```

### Implementación Técnica
```gdscript
# En sound_manager.gd
func play_3d_sound(position: Vector2, sound: AudioStream):
    # Calcular dirección relativa al jugador
    var direction = (position - player.global_position).normalized()
    
    # Reproducir sonido
    audio_player.play(sound)
    
    # Mostrar indicador visual en borde de pantalla
    var screen_edge = get_screen_edge_from_direction(direction)
    sound_indicator.show_at(screen_edge, 1.0)  # 1.0 segundos visible

# En hazard.gd
func activate():
    # Visual
    particles.emitting = true
    warning_icon.visible = true
    
    # Auditivo
    audio_player.play(eruption_sound)
    
    # HUD
    hud.show_warning("HAZARD", position=global_position)
```

---

## 6. Remapeo Completo de Controles

### Requisito
- **Todos los inputs** deben ser remapeables (keyboard, mouse, controller)
- **Múltiples bindings** por acción (ej: "Interact" = E, F, Enter, Controller X)
- **Perfiles guardables**: Hasta 5 perfiles de controles
- **Reset a defaults**: Botón para restaurar configuración por defecto

### Cómo Testear
```
[PASS] Jugador puede cambiar "move_up" de W a Flecha Arriba, guardar, y funciona
[PASS] Jugador puede asignar MÚLTIPLES teclas a misma acción (ej: "Interact" = E + F + Enter)
[PASS] Jugador puede guardar perfil como "Profile 2", cambiar controles, y volver a "Profile 1" sin pérdida
[PASS] Botón "Reset to Defaults" restaura todos los controles a configuración original
[FAIL] Algunas acciones no son remapeables (ej: "Pause" hardcoded en Escape)
[FAIL] Remapear una acción borra otras bindings (ej: cambiar W borra A, S, D)
[FAIL] No hay forma de guardar/restaurar perfiles
```

### Implementación Técnica
```gdscript
# En input_settings.gd
var default_inputs = {
    "move_up": [KEY_W, KEY_UP],
    "move_down": [KEY_S, KEY_DOWN],
    "move_left": [KEY_A, KEY_LEFT],
    "move_right": [KEY_D, KEY_RIGHT],
    "interact": [KEY_E, KEY_F, KEY_ENTER],
    "scan": [KEY_Q, KEY_X],
    "pause": [KEY_ESCAPE, KEY_P, KEY_START],
}

func save_profile(profile_name: String):
    var config = ConfigFile.new()
    for action in InputMap.get_actions():
        var events = InputMap.action_get_events(action)
        config.set_value(profile_name, action, events)
    config.save("user://input_profiles/%s.cfg" % profile_name)

func load_profile(profile_name: String):
    var config = ConfigFile.new()
    config.load("user://input_profiles/%s.cfg" % profile_name)
    for action in config.get_section_keys(profile_name):
        var events = config.get_value(profile_name, action)
        InputMap.action_erase_events(action)
        for event in events:
            InputMap.action_add_event(action, event)
```

---

## 7. Alternativas a Pulsaciones Rápidas

### Requisito
- **Toggle vs. Hold**: Todas las acciones de "mantener" deben poder ser "toggle"
- **Ventana de input**: Acciones de timing deben tener ventana mínima de 200ms (0.2s)
- **Slow-motion**: Opción para reducir velocidad de juego a 0.5x o 0.75x

### Cómo Testear
```
[PASS] Acción "Block" puede ser toggle (presiona una vez = bloquea infinitamente hasta presionar de nuevo) O hold (mantener = bloquea)
[PASS] Acción "Dodge" puede ser toggle (dodge automático cada 2 segundos) O hold (tradicional)
[PASS] Puzzle de timing (ej: cruzar hazard) tiene ventana de 200ms mínimo (medir con cronómetro)
[PASS] Slow-motion 0.5x: ventana de timing se duplica (200ms → 400ms efectivo)
[FAIL] Acción requiere mantener botón por >3 segundos sin alternativa toggle
[FAIL] Puzzle requiere timing de <100ms (imposible para motor-impaired players)
[FAIL] No hay slow-motion option
```

### Implementación Técnica
```gdscript
# En player_controller.gd
@export var toggle_block: bool = false  # Opción en settings
var is_blocking: bool = false

func _input(event):
    if event.is_action_pressed("block"):
        if toggle_block:
            is_blocking = !is_blocking  # Toggle
        else:
            is_blocking = true  # Hold
    elif event.is_action_released("block") and !toggle_block:
        is_blocking = false

# En hazard_puzzle.gd
@export var timing_window: float = 0.2  # 200ms mínimo
@export var slow_motion_multiplier: float = 1.0  # 1.0 = normal, 0.5 = half speed

func check_timing():
    var effective_window = timing_window / slow_motion_multiplier
    if player_input_time >= effective_window:
        return SUCCESS  # Jugador acertó
    else:
        return FAILURE  # Jugador falló
```

---

## 8. Velocidad de Juego Ajustable

### Requisito
- **Opciones**: 0.5x, 0.75x, 1.0x (normal), 1.25x (speedrun)
- **Afecta todo**: Movimiento, puzzles, combat, cinemáticas, timers
- **No afecta**: FPS target (siempre 60 FPS), input latency (siempre <50ms)

### Cómo Testear
```
[PASS] 0.5x: Movimiento de jugador es 50% más lento (medir distancia por segundo)
[PASS] 0.5x: Timers de puzzles duran 2x más (60s → 120s)
[PASS] 0.5x: Enemigos se mueven 50% más lento (medir velocidad)
[PASS] 0.5x: Cinemáticas se reproducen 50% más lento (medir duración)
[PASS] 1.25x: Todo es 25% más rápido, juego sigue a 60 FPS
[FAIL] 0.5x: FPS cae a 30 (debe mantener 60)
[FAIL] 0.5x: Input latency aumenta (debe mantener <50ms)
[FAIL] 0.5x: Solo afecta movimiento, no puzzles/combat (debe afectar TODO)
```

### Implementación Técnica
```gdscript
# En engine_settings.gd
@export var time_scale: float = 1.0  # 0.5, 0.75, 1.0, 1.25

func _ready():
    Engine.time_scale = time_scale

# En timer_puzzle.gd
@export var base_duration: float = 60.0  # 60 segundos

func _ready():
    var effective_duration = base_duration / Engine.time_scale
    timer.start(effective_duration)
```

---

## 9. Dificultad Separada por Componentes

### Requisito
- **No "Easy/Normal/Hard" genérico**
- **Sliders independientes**:
  - Combat Difficulty: 0-100% (daño recibido, daño infligido, enemy health)
  - Puzzle Time: 0-100% (timers más largos/cortos)
  - Hazard Damage: 0-100% (daño de hazards)
  - Enemy Aggression: 0-100% (qué tan rápido atacan enemigos)
  - Aim Assist: 0-100% (para cualquier targeting)

### Cómo Testear
```
[PASS] Combat Difficulty 0%: Jugador recibe 50% daño, inflige 200% daño, enemigos tienen 50% HP
[PASS] Combat Difficulty 100%: Jugador recibe 200% daño, inflige 50% daño, enemigos tienen 200% HP
[PASS] Puzzle Time 0%: Timers son 200% más largos (60s → 120s)
[PASS] Puzzle Time 100%: Timers son 50% más cortos (60s → 30s)
[PASS] Hazard Damage 0%: Hazards no hacen daño (solo visual)
[PASS] Hazard Damage 100%: Hazards hacen 200% daño
[PASS] Enemy Aggression 0%: Enemigos atacan cada 5 segundos
[PASS] Enemy Aggression 100%: Enemigos atacan cada 1 segundo
[PASS] Aim Assist 0%: No hay asistencia (reticle no se pega a enemigos)
[PASS] Aim Assist 100%: Reticle se "pega" fuertemente a enemigos (casi auto-aim)
[FAIL] Un solo slider "Difficulty" que cambia todo a la vez
[FAIL] No hay forma de ajustar componentes individualmente
```

### Implementación Técnica
```gdscript
# En difficulty_settings.gd
@export var combat_difficulty: float = 0.5  # 0.0-1.0
@export var puzzle_time: float = 0.5  # 0.0-1.0
@export var hazard_damage: float = 0.5  # 0.0-1.0
@export var enemy_aggression: float = 0.5  # 0.0-1.0
@export var aim_assist: float = 0.5  # 0.0-1.0

func get_damage_multiplier():
    return 0.5 + (combat_difficulty * 1.5)  # 0.5x-2.0x

func get_puzzle_timer_multiplier():
    return 2.0 - (puzzle_time * 1.5)  # 2.0x-0.5x

func get_hazard_damage_multiplier():
    return 2.0 - (hazard_damage * 2.0)  # 2.0x-0.0x

func get_enemy_attack_speed():
    return 5.0 - (enemy_aggression * 4.0)  # 5s-1s entre ataques

func get_aim_assist_strength():
    return aim_assist * 0.8  # 0.0-0.8 (80% max assist)
```

---

## 10. Guardado Frecuente y Reintentos Razonables

### Requisito
- **Autosave**: Cada 60 segundos de gameplay
- **Checkpoint**: Al completar cada sala/arena/puzzle (3-5 minutos máximo)
- **Manual save**: 10 slots, accesible desde pause menu (fuera de combat)
- **Quick load**: Tecla rápida para cargar último checkpoint (ej: F9)

### Cómo Testear
```
[PASS] Jugador juega 60 segundos, autosave se activa (verificar archivo user://autosave.json)
[PASS] Jugador completa sala, checkpoint save se activa (verificar user://checkpoint.json)
[PASS] Jugador presiona F5 en pause menu, puede guardar en slot 1-10
[PASS] Jugador muere, reaparece en checkpoint (máximo 3-5 minutos atrás)
[PASS] Jugador presiona F9, carga último checkpoint instantáneamente (<2 segundos)
[FAIL] No hay autosave (jugador debe guardar manualmente cada 10 minutos)
[FAIL] Checkpoint está a 15 minutos atrás (jugador pierde progreso significativo)
[FAIL] Quick load tarda 10+ segundos (jugador se frustra)
```

### Implementación Técnica
```gdscript
# En game_manager.gd
var autosave_timer: float = 0.0
var autosave_interval: float = 60.0  # 60 segundos

func _process(delta):
    autosave_timer += delta
    if autosave_timer >= autosave_interval:
        save_game("autosave")
        autosave_timer = 0.0

func save_game(slot_name: String):
    var save_data = {
        "player_position": player.global_position,
        "elena_safety": elena_safety,
        "prototype_integrity": prototype_integrity,
        "civilian_aid": civilian_aid,
        "completed_phases": completed_phases,
        # ... más datos
    }
    var file = FileAccess.open("user://savegame_%s.json" % slot_name, FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

func load_game(slot_name: String):
    var file = FileAccess.open("user://savegame_%s.json" % slot_name, FileAccess.READ)
    var save_data = JSON.parse_string(file.get_as_text())
    file.close()
    
    player.global_position = Vector2(save_data["player_position"])
    elena_safety = save_data["elena_safety"]
    # ... restaurar más datos
```

---

## 11. Compatibilidad con Teclado, Mando y Asistencia

### Requisito
- **Teclado**: Todas las acciones accesibles con teclado (WASD + teclas adicionales)
- **Mando**: Todas las acciones accesibles con mando (Xbox/PlayStation layout)
- **One-handed**: Esquema preconfigurado para una mano (teclado o mando)
- **Asistencia**: Opción para que segundo jugador controle acciones secundarias (ej: P2 controla menú, P1 controla movimiento)

### Cómo Testear
```
[PASS] Juego completo con teclado: WASD (movimiento), E (interactuar), Q (scan), Space (dodge), etc.
[PASS] Juego completo con mando: L-stick (movimiento), X (interactuar), LB (scan), B (dodge), etc.
[PASS] One-handed keyboard: Teclas A, S, D, W, E, Space accesibles con una mano (mano derecha o izquierda)
[PASS] One-handed controller: Todos los botones accesibles con una mano (izquierda o derecha)
[PASS] Asistencia: P2 puede presionar Start para pausar, navegar menús mientras P1 controla personaje
[FAIL] Acción requiere teclado Y mando simultáneamente (ej: "Presiona E + X")
[FAIL] Menú solo navegable con mouse (no con teclado/mando)
[FAIL] No hay esquema one-handed preconfigurado
```

### Implementación Técnica
```gdscript
# En input_settings.gd
var one_handed_keyboard = {
    "move_up": [KEY_W],
    "move_down": [KEY_S],
    "move_left": [KEY_A],
    "move_right": [KEY_D],
    "interact": [KEY_E],
    "scan": [KEY_Q],
    "dodge": [KEY_SPACE],
    "pause": [KEY_ESCAPE],
}

var one_handed_controller = {
    "move_up": [JOY_BUTTON_LEFT_STICK_UP],
    "move_down": [JOY_BUTTON_LEFT_STICK_DOWN],
    "move_left": [JOY_BUTTON_LEFT_STICK_LEFT],
    "move_right": [JOY_BUTTON_LEFT_STICK_RIGHT],
    "interact": [JOY_BUTTON_A],
    "scan": [JOY_BUTTON_LEFT_SHOULDER],
    "dodge": [JOY_BUTTON_B],
    "pause": [JOY_BUTTON_START],
}

func apply_one_handed_scheme(hand: String, device: String):
    if device == "keyboard":
        for action in one_handed_keyboard:
            InputMap.action_erase_events(action)
            for key in one_handed_keyboard[action]:
                var event = InputEventKey.new()
                event.keycode = key
                InputMap.action_add_event(action, event)
    elif device == "controller":
        # Similar para controller
```

---

## 12. Pruebas con Usuarios con Distintas Discapacidades

### Requisito
- **Testear con al menos 10 usuarios** en cada categoría:
  - Discapacidad motora (dificultad con inputs rápidos, precisión)
  - Discapacidad visual (ceguera, baja visión, daltonismo)
  - Discapacidad auditiva (sordera, hipoacusia)
  - Discapacidad cognitiva (dificultad con puzzles complejos, timing)
- **Métricas**: Tasa de completación, tiempo promedio, frustración reportada (escala 1-5)
- **Iterar**: Si tasa de completación <80% en alguna categoría, REVISAR diseño

### Cómo Testear
```
[PASS] 10 usuarios con discapacidad motora completan Phase 1-3 con esquema one-handed
[PASS] Tasa de completación: 9/10 = 90% (>80% requerido)
[PASS] Tiempo promedio: 25 minutos (similar a usuarios sin discapacidad: 22 minutos)
[PASS] Frustración reportada: 2.1/5.0 (<3.0 requerido)
[PASS] 10 usuarios con discapacidad visual completan con audio description + screen reader
[PASS] 10 usuarios con discapacidad auditiva completan con subtítulos + indicadores visuales
[PASS] 10 usuarios con discapacidad cognitiva completan con hints activados, timers extendidos
[FAIL] Tasa de completación 5/10 = 50% (<80%, REVISAR)
[FAIL] Frustración reportada 4.2/5.0 (>3.0, REVISAR)
```

### Protocolo de Test

**Fase 1: Reclutamiento**
- Contactar organizaciones de discapacidad (ej: AbleGamers, SpecialEffect)
- Ofrecer compensación ($50-100 por sesión de 2 horas)
- Obtener consentimiento informado (grabación de sesión, uso de feedback)

**Fase 2: Sesión de Test**
- Duración: 2 horas (1 hora gameplay, 1 hora entrevista)
- Grabar pantalla, audio, expresiones faciales (con permiso)
- Observar sin ayudar (dejar que usuario luche, tomar notas)
- Medir: tiempo por sección, muertes, hints usados, pausas

**Fase 3: Entrevista**
- Preguntas abiertas: "¿Qué fue frustrante?", "¿Qué funcionó bien?"
- Escala 1-5: "¿Qué tan difícil fue X?", "¿Qué tan claro fue Y?"
- Sugerencias: "¿Qué cambiarías?"

**Fase 4: Iteración**
- Compilar feedback de 10 usuarios por categoría
- Identificar patrones: "5 usuarios reportaron que puzzle X es imposible"
- Priorizar: Arreglar problemas que afectan >50% de usuarios
- Re-testear: Volver a testear con mismos usuarios después de arreglos

---

## Summary: Checklist de Accesibilidad

Antes de lanzar, verificar:

- [ ] **Texto**: 16px mínimo, escala 75-200%, no se corta, no se pixela
- [ ] **Contraste**: 4.5:1 mínimo, modo alto contraste funciona, 12 modos daltonismo
- [ ] **Subtítulos**: 4 tamaños, 4 colores, 3 fondos, borde configurable
- [ ] **Hablantes**: Etiquetas siempre visibles, color por personaje
- [ ] **Indicadores**: Sonidos tienen visuales, visuales tienen sonidos, direccionalidad clara
- [ ] **Controles**: Todo remapeable, múltiples bindings, 5 perfiles, reset a defaults
- [ ] **Pulsaciones**: Toggle/hold para todo, ventana 200ms mínimo, slow-motion 0.5x/0.75x
- [ ] **Velocidad**: 0.5x, 0.75x, 1.0x, 1.25x, afecta todo, mantiene 60 FPS
- [ ] **Dificultad**: Sliders independientes (combat, puzzle, hazard, aggression, aim assist)
- [ ] **Guardado**: Autosave 60s, checkpoint 3-5 min, manual 10 slots, quick load <2s
- [ ] **Inputs**: Teclado completo, mando completo, one-handed, asistencia P2
- [ ] **Tests**: 10 usuarios por categoría, >80% completación, <3.0 frustración

**Si algún ítem falla: NO LANZAR. Iterar hasta que todos pasen.**
