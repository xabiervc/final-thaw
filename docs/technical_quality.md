# FINAL THAW — Technical Quality Standards

## 1. Matriz de Plataformas

### Plataformas Objetivo

| Plataforma | Versión Mínima | Resolución Target | FPS Target | Estado |
|------------|----------------|-------------------|------------|--------|
| **Windows** | 10 (64-bit) | 1920x1080 | 60 locked | ✅ Primary |
| **macOS** | 11 (Big Sur) | 1920x1080 | 60 locked | ⚠️ Secondary (test required) |
| **Linux** | Ubuntu 20.04 | 1920x1080 | 60 locked | ⚠️ Secondary (test required) |
| **Steam Deck** | SteamOS 3.0 | 1280x800 | 60 locked | ⚠️ Secondary (test required) |

### Requisitos de Hardware

**Mínimos (Windows)**:
- CPU: Intel i5-6600K / AMD Ryzen 5 1600
- GPU: NVIDIA GTX 1060 6GB / AMD RX 580
- RAM: 8 GB
- Storage: 4 GB (SSD recomendado)

**Recomendados (Windows)**:
- CPU: Intel i7-8700K / AMD Ryzen 7 3700X
- GPU: NVIDIA RTX 3060 / AMD RX 6700 XT
- RAM: 16 GB
- Storage: 4 GB (SSD requerido)

### Criterios de Soporte

| Criterio | Windows | macOS | Linux | Steam Deck |
|----------|---------|-------|-------|------------|
| **Export templates** | ✅ Incluidos en Godot 4.x | ✅ Incluidos | ✅ Incluidos | ✅ Incluidos |
| **Testing hardware** | ✅ GTX 1060, RTX 3060 | ❌ No disponible | ❌ No disponible | ❌ No disponible |
| **Decisión** | **LANZAR DÍA 1** | **Post-launch (si hay hardware)** | **Post-launch (si hay hardware)** | **Post-launch (si hay hardware)** |

**Regla**: No prometer soporte para plataformas que no se pueden testear físicamente.

---

## 2. Objetivos de Rendimiento

### Métricas Objetivo

| Métrica | Target | Método de Medición | Frecuencia de Test |
|---------|--------|-------------------|-------------------|
| **FPS** | 60 locked (±2 FPS) | Godot Profiler, Steam Overlay | Cada build |
| **Frame Time** | <16.67ms (60 FPS) | Godot Profiler → Monitor tab | Cada build |
| **Input Latency** | <50ms | High-speed camera (240 FPS), medir input→respuesta | Semanal |
| **Load Time (SSD)** | <2 segundos | Cronómetro, escena load a playable | Cada build |
| **Load Time (HDD)** | <5 segundos | Cronómetro, escena load a playable | Cada build |
| **Memory Peak** | <500 MB | Godot Debugger → Memory tab | Semanal |
| **VRAM Usage** | <1 GB | GPU monitoring tool (MSI Afterburner) | Semanal |

### Cómo Testear FPS

```
1. Abrir Godot Editor
2. Ir a: Debugger → Monitor → FPS
3. Ejecutar juego (F5)
4. Jugar Phase 13 (Final Thaw Station, nivel más pesado)
5. Observar FPS durante 5 minutos
6. [PASS] FPS nunca cae por debajo de 58
7. [FAIL] FPS cae por debajo de 55 (optimizar)
```

### Cómo Testear Input Latency

```
1. Configurar cámara a 240 FPS (4.17ms por frame)
2. Grabar pantalla + input (tecla presionada)
3. Reproducir en slow-motion
4. Contar frames entre:
   - Frame donde tecla se presiona (LED se enciende)
   - Frame donde personaje se mueve (sprite cambia)
5. Calcular: frames × 4.17ms = latency
6. [PASS] Latency <50ms (<12 frames a 240 FPS)
7. [FAIL] Latency >50ms (optimizar input pipeline)
```

### Optimizaciones Críticas

**Si FPS <60**:
1. Reducir particle count (máx 100 partículas activas)
2. Reducir shadow quality (bajar de 2048 a 1024)
3. Usar occlusion culling (no renderizar lo que cámara no ve)
4. Batch static geometry (combinar meshes estáticos)

**Si Memory >500MB**:
1. Reducir texture size (máx 2048x2048 para personajes, 4096x4096 para backgrounds)
2. Usar texture compression (BPTC para GPU moderna, ETC2 para móvil)
3. Liberar recursos no usados: `ResourceLoader.unload()`
4. Usar object pooling (no crear/destruir enemigos, activar/desactivar)

---

## 3. Presupuesto de Memoria

### Límites por Categoría

| Categoría | Presupuesto | Cómo Medir | Target |
|-----------|-------------|------------|--------|
| **Textures** | <200 MB | Godot Debugger → Memory → Textures | 150-180 MB |
| **Audio** | <100 MB | Godot Debugger → Memory → Audio | 80-90 MB |
| **Scripts** | <50 MB | Godot Debugger → Memory → Scripts | 30-40 MB |
| **Scenes** | <100 MB | Godot Debugger → Memory → Nodes | 80-90 MB |
| **Buffers** | <50 MB | Godot Debugger → Memory → VBuffers | 30-40 MB |
| **Total** | **<500 MB** | Godot Debugger → Memory → Total | **400-450 MB** |

### Cómo Optimizar Textures

```gdscript
# En project.godot
[rendering]
textures/canvas_textures/default_filter=true  # Suavizado
textures/vram_compression/import_etc=true  # Compresión para móvil
textures/vram_compression/import_bptc=true  # Compresión para PC

# En cada textura (import settings)
Compression Mode: VRAM Compressed
Compression: BPTC (para PC) / ETC2 (para móvil)
Mipmaps: Enabled (para texturas 3D)
```

### Cómo Optimizar Audio

```gdscript
# En cada archivo de audio (import settings)
Format: Ogg Vorbis
Bitrate: 64 kbps (para SFX), 128 kbps (para música)
Max Polyphony: 32 voices (no más de 32 sonidos simultáneos)
```

---

## 4. Estrategia de Guardado y Migración de Partidas

### Formato de Guardado

```json
{
  "version": "1.0.0",
  "timestamp": "2026-09-30T10:00:00Z",
  "playtime_seconds": 3600,
  "completed_phases": ["phase_0", "phase_1", "phase_2"],
  "elena_safety": 3,
  "prototype_integrity": 3,
  "civilian_aid": 5,
  "evidence_choice": null,
  "memory_fragments": ["elena_memory_1", "marcus_memory_2"],
  "story_flags": {
    "rescued_shelter_civilians": true,
    "vehicle_repaired_cleanly": true
  },
  "player_position": {"x": 1024, "y": 768},
  "active_character": "elena"
}
```

### Migración entre Versiones

**Regla**: Partidas de versión 1.X.X son compatibles con 1.Y.Y (Y > X). No hay garantía para versiones mayores (2.X.X).

**Implementación**:
```gdscript
# En game_manager.gd
func load_game(slot_name: String):
    var file = FileAccess.open("user://savegame_%s.json" % slot_name, FileAccess.READ)
    var save_data = JSON.parse_string(file.get_as_text())
    file.close()
    
    # Verificar versión
    var save_version = save_data.get("version", "0.0.0")
    var current_version = ProjectSettings.get("application/config/version")
    
    if save_version != current_version:
        save_data = migrate_save_data(save_data, save_version, current_version)
    
    # Restaurar datos
    restore_from_save(save_data)

func migrate_save_data(save_data: Dictionary, from_version: String, to_version: String):
    # Ejemplo: migrar de 1.0.0 a 1.1.0 (añade nuevo campo)
    if from_version == "1.0.0" and to_version >= "1.1.0":
        save_data["new_field"] = default_value
    
    # Ejemplo: migrar de 1.1.0 a 1.2.0 (cambia nombre de campo)
    if from_version == "1.1.0" and to_version >= "1.2.0":
        save_data["new_name"] = save_data["old_name"]
        save_data.erase("old_name")
    
    return save_data
```

### Backup de Partidas

**Regla**: Cada partida tiene backup automático. Si archivo principal se corrompe, se restaura backup.

**Implementación**:
```gdscript
func save_game(slot_name: String):
    # Guardar principal
    var file = FileAccess.open("user://savegame_%s.json" % slot_name, FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()
    
    # Guardar backup
    var backup_file = FileAccess.open("user://savegame_%s.backup.json" % slot_name, FileAccess.WRITE)
    backup_file.store_string(JSON.stringify(save_data))
    backup_file.close()

func load_game(slot_name: String):
    # Intentar cargar principal
    var file = FileAccess.open("user://savegame_%s.json" % slot_name, FileAccess.READ)
    if file == null:
        # Principal no existe, cargar backup
        file = FileAccess.open("user://savegame_%s.backup.json" % slot_name, FileAccess.READ)
        if file == null:
            push_error("No save file found for slot: %s" % slot_name)
            return
    
    var save_data = JSON.parse_string(file.get_as_text())
    file.close()
    
    # Verificar integridad (checksum)
    if not verify_save_data(save_data):
        push_error("Save file corrupted, attempting backup restore")
        # Intentar cargar backup
        file = FileAccess.open("user://savegame_%s.backup.json" % slot_name, FileAccess.READ)
        if file:
            save_data = JSON.parse_string(file.get_as_text())
            file.close()
        else:
            push_error("Backup also corrupted, starting new game")
            reset_new_game()
            return
    
    restore_from_save(save_data)
```

---

## 5. Telemetría Respetuosa con la Privacidad

### Qué Recoger (Opcional, Anonimizado)

| Dato | Propósito | Anonimización | Opt-in |
|------|-----------|---------------|--------|
| **Tiempo de juego** | Balancear dificultad | Sin ID de usuario, solo sesión | ✅ Sí |
| **Muertes por fase** | Identificar puntos de frustración | Sin ID, agregado por fase | ✅ Sí |
| **Decisiones (Civilian Aid, Evidence)** | Entender preferencias de jugadores | Sin ID, solo conteos | ✅ Sí |
| **Ending obtenido** | Balancear narrativa | Sin ID, solo tipo de ending | ✅ Sí |
| **FPS promedio** | Optimizar rendimiento | Sin ID, solo estadísticas | ✅ Sí |
| **Configuración de accesibilidad** | Mejorar opciones | Sin ID, solo qué opciones se usan | ✅ Sí |

### Qué NO Recoger

- ❌ Nombre de usuario
- ❌ Email o información personal
- ❌ IP address
- ❌ Hardware ID
- ❌ Ubicación geográfica
- ❌ Historial de navegación
- ❌ Datos de terceros (Steam friends, etc.)

### Implementación (Privacy-First)

```gdscript
# En telemetry_manager.gd
var telemetry_enabled: bool = false  # Default OFF, jugador debe activar

func _ready():
    # Preguntar al jugador en primer launch
    if not ProjectSettings.has_setting("user/telemetry_consent"):
        show_telemetry_consent_dialog()
    else:
        telemetry_enabled = ProjectSettings.get_setting("user/telemetry_consent")

func send_telemetry(event_name: String, data: Dictionary):
    if not telemetry_enabled:
        return
    
    # Anonimizar: remover cualquier ID
    data.erase("user_id")
    data.erase("session_id")
    data.erase("ip_address")
    
    # Agregar solo datos necesarios
    var anonymized_data = {
        "event": event_name,
        "timestamp": Time.get_unix_time_from_system(),
        "version": ProjectSettings.get("application/config/version"),
        "platform": OS.get_name(),
        "data": data
    }
    
    # Enviar (batch, no en tiempo real)
    telemetry_queue.append(anonymized_data)
    if telemetry_queue.size() >= 10:
        flush_telemetry_queue()

func flush_telemetry_queue():
    # Enviar a servidor (ej: self-hosted Matomo)
    var http = HTTPRequest.new()
    http.request("https://telemetry.finalthaw.com/collect", ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(telemetry_queue))
    telemetry_queue.clear()
```

---

## 6. Plan de Localización

### Idiomas Objetivo

| Idioma | Prioridad | Traducción | Testing | Estado |
|--------|-----------|------------|---------|--------|
| **Inglés** | Primary | Nativo (desarrollador) | ✅ Sí | ✅ Listo |
| **Español** | Primary | Nativo (desarrollador) | ✅ Sí | ✅ Listo |
| **Francés** | Secondary | Profesional (contratar) | ⚠️ Parcial | ⏳ Pendiente |
| **Alemán** | Secondary | Profesional (contratar) | ⏳ No | ⏳ Pendiente |
| **Japonés** | Tertiary | Profesional + cultural check | ⏳ No | ⏳ Pendiente |
| **Chino Simplificado** | Tertiary | Profesional + cultural check | ⏳ No | ⏳ Pendiente |

### Implementación Técnica

```gdscript
# En localization_manager.gd
var supported_locales = ["en", "es", "fr", "de", "ja", "zh"]

func _ready():
    # Detectar locale del sistema
    var system_locale = OS.get_locale_language()
    if system_locale in supported_locales:
        TranslationServer.set_locale(system_locale)
    else:
        TranslationServer.set_locale("en")  # Fallback a inglés

# En cada texto del juego
label.text = tr("greeting_message")  # Busca en translations/*.csv

# En translations/greeting.csv:
# keys,en,es,fr,de,ja,zh
# greeting_message,"Hello","Hola","Bonjour","Hallo","こんにちは","你好"
```

### Criterios de Calidad

- ✅ **No hardcodear texto**: Todo texto debe usar `tr()`
- ✅ **Contexto para traductores**: Comments en CSV explican contexto (ej: "greeting_message: NPC saluda al jugador")
- ✅ **Testing nativo**: Cada idioma probado por hablante nativo (no Google Translate)
- ✅ **UI flexible**: Texto en alemán puede ser 30% más largo que inglés, UI debe acomodar

---

## 7. Pruebas de Regresión

### Qué Testear en Cada Build

| Test | Frecuencia | Cómo Automatizar | Criterio de Pass |
|------|------------|------------------|------------------|
| **Inicio de juego** | Cada build | Script: abrir juego, esperar MainMenu | MainMenu aparece en <5s, sin errores en Output |
| **Guardado/Carga** | Cada build | Script: guardar, cerrar, abrir, cargar | Partida carga, posición de jugador restaurada |
| **Fase 1 (movimiento)** | Cada build | Script: iniciar Fase 1, mover 10s | Jugador se mueve, FPS >55, sin crashes |
| **Fase 3 (combate)** | Cada build | Script: iniciar Fase 3, matar 1 enemigo | Enemigo muere, Marcus no muere, FPS >55 |
| **Fase 6 (puzzle)** | Cada build | Script: resolver puzzle | Puzzle se resuelve, puerta se abre, checkpoint save |
| **Accesibilidad** | Semanal | Script: activar todas las opciones de accesibilidad | Todas las opciones funcionan, juego sigue jugable |

### Automatización con GDScript

```gdscript
# En tests/regression_test.gd
func test_game_start():
    var start_time = Time.get_ticks_msec()
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
    
    # Esperar 5 segundos
    await get_tree().create_timer(5.0).timeout
    
    var load_time = Time.get_ticks_msec() - start_time
    
    # Verificar que MainMenu está activo
    var main_menu = get_tree().current_scene
    assert(main_menu.name == "MainMenu", "MainMenu no se cargó")
    assert(load_time < 5000, "MainMenu tardó más de 5s en cargar: %dms" % load_time)
    
    print("[PASS] test_game_start")

func test_save_load():
    # Guardar
    GameManager.save_game("test_slot")
    
    # Cerrar (simular)
    var player_position_before = player.global_position
    
    # Cargar
    GameManager.load_game("test_slot")
    var player_position_after = player.global_position
    
    # Verificar
    assert(player_position_before == player_position_after, "Posición no se restauró: %s → %s" % [player_position_before, player_position_after])
    
    print("[PASS] test_save_load")
```

---

## 8. Pruebas de Carga

### Escenarios de Carga

| Escenario | Descripción | Métrica | Target |
|-----------|-------------|---------|--------|
| **10 jugadores simultáneos** | No aplica (single-player) | N/A | N/A |
| **100 enemigos en pantalla** | Stress test de combate | FPS, Memory | FPS >50, Memory <600MB |
| **1000 partículas activas** | Stress test de efectos | FPS, Memory | FPS >55, Memory <550MB |
| **20 saves simultáneos** | Stress test de I/O | Load time | <3s por save |

### Cómo Testear

```
1. Abrir Godot Editor
2. Ir a: Debugger → Monitor → Nodes
3. Ejecutar juego (F5)
4. Spawnear 100 enemigos (debug command: `spawn_enemies(100)`)
5. Observar FPS durante 1 minuto
6. [PASS] FPS >50 todo el minuto
7. [FAIL] FPS <50 por >5 segundos (optimizar)
```

---

## 9. Sistema de Errores Recuperables

### Tipos de Errores

| Error | Severidad | Recuperación | Ejemplo |
|-------|-----------|--------------|---------|
| **Crítico** | Juego no puede continuar | Reiniciar juego, cargar backup | Save file corrupto, escena no existe |
| **Mayor** | Funcionalidad rota, juego continúa | Reintentar, skippear sección | Enemy AI se cuelga, puzzle no se resuelve |
| **Menor** | Molesto, no bloquea progreso | Ignorar, workaround temporal | Subtitle no aparece, sonido no se reproduce |
| **Cosmético** | Visual, no afecta gameplay | Ignorar hasta parche | Textura parpadea, typo en diálogo |

### Manejo de Errores

```gdscript
# En error_handler.gd
func handle_error(error_type: String, context: String, recoverable: bool):
    push_error("[%s] %s: %s" % [error_type, context, error_message])
    
    if error_type == "CRITICAL":
        # Mostrar diálogo al jugador
        show_error_dialog(
            title="Critical Error",
            message="The game encountered a critical error and must restart. Your progress has been saved."
        )
        
        # Guardar progreso
        GameManager.save_game("autosave")
        
        # Reiniciar
        get_tree().reload_current_scene()
    
    elif error_type == "MAJOR":
        # Intentar recuperar
        if recoverable:
            retry_operation()
        else:
            # Skippear sección
            skip_current_section()
    
    elif error_type == "MINOR":
        # Loggear, continuar
        log_error_for_telemetry(error_message)
    
    elif error_type == "COSMETIC":
        # Ignorar hasta parche
        pass
```

---

## 10. Criterios de "Listo para Vertical Slice" y "Listo para Producción"

### Listo para Vertical Slice (Phase 0-6, 25 minutos jugables)

**Requisitos Técnicos**:
- [ ] 60 FPS locked en Phase 6 (Flooded Shelter)
- [ ] Load times <2s entre escenas
- [ ] Input latency <50ms
- [ ] Memory <500MB peak
- [ ] No crashes en 1 hora de gameplay continuo
- [ ] Guardado/carga funciona (autosave + checkpoint)

**Requisitos de Diseño**:
- [ ] Core gameplay loop completo (movimiento, interacción, puzzle, hazard, rescue)
- [ ] 1 decisión irreversible (rescue 0-3 civilians)
- [ ] 1 variación narrativa (NPCs reaccionan diferente según rescates)
- [ ] 1 secuencia de recuperación (muerte → checkpoint restart)
- [ ] Cliffhanger al final (Marcus: "I'm at the perimeter. Coming in.")

**Requisitos de Accesibilidad**:
- [ ] Subtítulos configurables (tamaño, color, fondo)
- [ ] Remapeo completo de controles
- [ ] Toggle/hold para todas las acciones
- [ ] Indicadores visuales + auditivos redundantes

**Requisitos de QA**:
- [ ] 10 playtesters completan vertical slice
- [ ] Tasa de completación >80% (8/10 completan)
- [ ] Frustración reportada <3.0/5.0
- [ ] Feedback compilado, priorizado, acciones definidas

---

### Listo para Producción (Todas las Phases, 12-15 horas)

**Requisitos Técnicos**:
- [ ] 60 FPS locked en TODAS las phases (especialmente Phase 13, 14)
- [ ] Load times <2s en todo el juego
- [ ] Input latency <50ms consistente
- [ ] Memory <500MB todo el juego
- [ ] No crashes en 10 horas de gameplay continuo
- [ ] Guardado/carga funciona (autosave + checkpoint + manual + quick load)
- [ ] Backup de partidas funciona (corrupción → restore)

**Requisitos de Diseño**:
- [ ] Todas las 16 phases implementadas, jugables de inicio a fin
- [ ] 3 endings completos (Public/Guarded/Fragile Thaw)
- [ ] 24 memory fragments coleccionables
- [ ] 10 civilian rescues opcionales
- [ ] Evidence choice (preserve/erase) con consecuencias mecánicas
- [ ] New Game+ desbloqueado tras completar juego

**Requisitos de Accesibilidad**:
- [ ] TODOS los requisitos de `docs/accessibility_requirements.md` implementados
- [ ] 10 usuarios con discapacidad motora testean, >80% completan
- [ ] 10 usuarios con discapacidad visual testean, >80% completan
- [ ] 10 usuarios con discapacidad auditiva testean, >80% completan
- [ ] 10 usuarios con discapacidad cognitiva testean, >80% completan

**Requisitos de QA**:
- [ ] Regression tests automatizados pasan (100%)
- [ ] Load tests pasan (100 enemigos, 1000 partículas, 20 saves)
- [ ] No bugs críticos o mayores abiertos (solo menores/cosméticos permitidos)
- [ ] 100 playtesters completan juego completo
- [ ] Tasa de completación >70% (70/100 completan)
- [ ] Metacritic score objetivo: 85+ (pre-lanzamiento, reviewer builds)

**Requisitos de Localización**:
- [ ] Inglés y español 100% traducidos, testeados por nativos
- [ ] Francés, alemán, japonés, chino: al menos menús y tutorial traducidos
- [ ] UI acomoda texto 30% más largo (alemán) sin cortarse

**Requisitos de Plataforma**:
- [ ] Windows export probado en GTX 1060 y RTX 3060
- [ ] macOS, Linux, Steam Deck: o probados físicamente o declarados "no soportados oficialmente"

---

## Summary: Checklist Técnico

Antes de vertical slice:
- [ ] 60 FPS en Phase 6
- [ ] Load times <2s
- [ ] Input latency <50ms
- [ ] Memory <500MB
- [ ] No crashes en 1 hora
- [ ] Guardado/carga funciona
- [ ] 1 decisión irreversible
- [ ] 1 variación narrativa
- [ ] 1 recuperación tras fracaso
- [ ] Cliffhanger al final
- [ ] Accesibilidad básica (subtítulos, remap, toggle/hold)
- [ ] 10 playtesters, >80% completan

Antes de producción (lanzamiento):
- [ ] 60 FPS en TODAS las phases
- [ ] 3 endings completos
- [ ] 24 memory fragments
- [ ] 10 civilian rescues
- [ ] TODA la accesibilidad implementada
- [ ] 40 usuarios con discapacidad testean, >80% completan
- [ ] Regression/load tests pasan
- [ ] No bugs críticos/mayores
- [ ] 100 playtesters, >70% completan
- [ ] Windows probado, otras plataformas declaradas (soportadas o no)

**Si algún ítem falla: NO LANZAR. Iterar hasta que todos pasen.**
