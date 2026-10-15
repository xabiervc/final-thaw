extends Resource
class_name NarrativeText

## Menú principal
@export_group("Main Menu")
@export_multiline var menu_title: String = "Final Thaw\nVertical Slice"
@export_multiline var menu_context: String = """
Año 2047. El colapso climático ha sumido a las ciudades en caos.
Las tormentas no se detienen. Los refugios se inundan. La gente espera
que alguien tome decisiones imposibles.

Elena Vast, científica del proyecto Aster, y Marcus Reyes, oficial de
seguridad, deben cooperar para salvar lo que queda de la humanidad.

En esta demo, controlarás a Elena en un refugio de emergencia inundado.
Cada decisión afecta a quienes dependen de ti.
"""
@export var menu_start_button: String = "Iniciar Demo"
@export var menu_options_button: String = "Opciones"
@export var menu_credits_button: String = "Créditos"

## Visual equivalents of audio cues (accessibility)
@export_group("Sound cues")
@export var sound_cue_generator: String = "[Sonido] Generador en marcha"
@export var sound_cue_valves: String = "[Sonido] Las válvulas se abren"
@export var sound_cue_rescue: String = "[Sonido] Rescate completado"
@export var sound_cue_oxygen_empty: String = "[Sonido] Oxígeno agotado"

## HUD
@export_group("HUD")
@export var hud_oxygen_label: String = "Oxígeno: %d%%"
@export var hud_oxygen_low_threshold: float = 30.0
@export var hud_civilian_aid: String = "Ayuda civil %d/10"
@export var hud_prototype_integrity: String = "Prototipo %d/3"
@export var hud_elena_safety: String = "Elena %d/3"
@export var hud_fps: String = "FPS: %d"
@export var hud_civilian_trapped: String = "Civil: Atrapada"
@export var hud_civilian_rescued: String = "Civil: Rescatada"
@export var hud_civilian_dead: String = "Civil: Fallecida"

@export var hud_objective_start: String = "Objetivo: Activa el generador para restaurar la energía."
@export var hud_objective_power_on: String = "Objetivo: Abre las válvulas para drenar el agua y continuar."
@export var hud_objective_valves_open: String = "Objetivo: Decide si rescatas a la civil antes de alcanzar la salida."
@export var hud_objective_exit: String = "Objetivo: Alcanza la salida del refugio."

@export var hud_demo_completed: String = "Demo completada - %s"
@export var hud_demo_failed: String = "Demo fallida - Elena no sobrevivió"

## Interacciones
@export_group("Interactions")
@export var interact_power_console_off: String = "Activar generador"
@export var interact_power_console_on: String = "Generador en funcionamiento"
@export var interact_valve_closed: String = "Abrir válvula"
@export var interact_valve_open: String = "Válvula abierta"
@export var interact_civilian_trapped: String = "Rescatar"
@export var interact_civilian_rescued: String = "A salvo"

## Frases de la civil
@export_group("Civilian Dialogue")
@export var civilian_rescue_lines: Array[String] = [
	"Gracias... pensé que no saldría de aquí.",
	"No creí que volviera a ver a alguien.",
	"Mi familia está en el sector norte... ¿podrás llevarles ayuda?",
	"No tengo fuerzas para seguir. Gracias por intentarlo."
]

## Pantalla final
@export_group("Demo End")
@export var end_title_success: String = "Demo completada"
@export var end_title_failure: String = "Demo fallida"
@export var end_elena_alive: String = "Elena: Sobrevivió"
@export var end_elena_dead: String = "Elena: No sobrevivió"
@export var end_civilian_unknown: String = "Civil: Estado desconocido"

@export_multiline var end_power_restored: String = """
Refugio: energía restaurada.
Algunos sistemas de emergencia volvieron a funcionar.
"""
@export_multiline var end_valves_opened: String = """
Refugio: válvulas abiertas.
El agua comenzó a drenarse, pero demasiado tarde para algunos.
"""
@export_multiline var end_civilian_rescued: String = """
Refugio: civil rescatada.
Una vida más entre las que dependen de tus decisiones.
"""
@export_multiline var end_civilian_not_rescued: String = """
Refugio: civil no rescatada.
No todos pueden ser salvados. Eso también es una decisión.
"""

@export var end_button_menu: String = "Volver al menú"
@export var end_button_restart: String = "Reiniciar demo"

## Prompts y condiciones
@export_group("Prompts")
@export var prompt_instructions: String = "WASD / flechas: moverse   |   E: interactuar   |   Q / Tab: escanear   |   F2: guardar   F3: cargar   |   ESC: menú"
@export var prompt_condition: String = "AGUANTE %d%%  |  %s"
@export var prompt_aster_load: String = "Carga del Aster"

## HUD de las salas 3D y señalización de la bahía de pruebas
@export_group("Room HUD")
@export var hud_directive_header: String = "DIRECTIVA  ·  ASTER"
@export var hud_completed_header: String = "OBJETIVO COMPLETADO"
@export var hud_ctrl_move: String = "mover"
@export var hud_ctrl_interact: String = "interactuar"
@export var hud_ctrl_scan: String = "escanear"
@export var hud_ctrl_jump: String = "saltar"
@export var hud_ctrl_save: String = "guardar"
@export var hud_ctrl_load: String = "cargar"
@export var hud_ctrl_menu: String = "menú"
@export var hud_ctrl_run: String = "correr"
@export var hud_ctrl_crouch: String = "agacharse"
@export var hud_ctrl_hint: String = "pista"
@export var hud_key_space: String = "Espacio"
@export var hud_power_restored_title: String = "ENERGÍA RESTAURADA"
@export var hud_power_restored_body: String = "Generador auxiliar en línea. La esclusa B-4 tiene corriente."
@export var hud_power_lost_title: String = "SIN ENERGÍA"
@export var hud_power_lost_body: String = "El generador se ha detenido. La puerta de salida vuelve a bloquearse."
@export var hud_room_cleared_title: String = "SALA SUPERADA"
@export var hud_room_cleared_body: String = "Bahía de pruebas B: sistemas restaurados."
@export var test_room_sign_access: String = "B-1  ACCESO"
@export var test_room_sign_flood: String = "B-2  CONTROL DE INUNDACIONES"
@export var test_room_sign_generator: String = "B-3  GENERADOR"
@export var test_room_sign_airlock: String = "B-4  ESCLUSA"
@export var test_room_sign_shutter: String = "COMPUERTA 2 — SELLADA"
@export var test_room_gauge_mark: String = "MÁX. 14/03"
@export var test_room_sign_warming: String = "PUNTO DE CALOR"
@export var test_room_sign_gen_warning: String = "GENERADOR AUXILIAR — ACCESO POR EL ESTE  →"
@export var test_room_sign_lab: String = "LABORATORIO  →"

## Opciones
@export_group("Options")
@export var options_text_scale: String = "Escala de texto: %.2f"
@export var options_back_button: String = "Volver"
@export var options_high_contrast: String = "Alto contraste"
@export var options_reduced_motion: String = "Reducir movimiento"
@export var options_subtitle_background: String = "Fondo de subtítulos"
@export var options_subtitle_none: String = "Ninguno"
@export var options_subtitle_dim: String = "Tenue"
@export var options_subtitle_solid: String = "Sólido"
@export var options_colorblind_mode: String = "Modo daltonismo"
@export var options_colorblind_none: String = "Ninguno"
@export var options_colorblind_deuteranopia: String = "Deuteranopía"
@export var options_colorblind_protanopia: String = "Protanopía"
@export var options_colorblind_tritanopia: String = "Tritanopía"
@export var options_remap_title: String = "Controles"
@export var options_press_key: String = "Pulsa una tecla..."

## Créditos
@export_group("Credits")
@export_multiline var credits_title: String = "FINAL THAW\nPrototipo Fase 0"

## Refugio
@export_group("Shelter")
@export var shelter_intro: String = "E: generador, válvulas, rescate y salida. WASD/flechas para moverte. ESC: menú."
@export var shelter_scan: String = "Ruta: generador -> válvulas -> rescate opcional -> salida."
@export var shelter_power_restored: String = "Generador activado."
@export var shelter_power_already_on: String = "El generador ya está activo."
@export var shelter_valves_opened: String = "Válvulas abiertas. El oxígeno se está agotando."
@export var shelter_valves_need_power: String = "Activa primero el generador."
@export var shelter_civilian_rescued: String = "Civil rescatada. Aumenta la ayuda civil; partida guardada."
@export var shelter_civilian_blocked: String = "Abre las válvulas para llegar a la civil."
@export var shelter_exit_blocked: String = "La salida sigue bloqueada. Activa el generador y abre las válvulas."
@export var shelter_oxygen_empty: String = "Sin oxígeno. Reiniciando desde la entrada; tu rescate guardado se mantiene."
@export var shelter_yes: String = "SÍ"
@export var shelter_no: String = "NO"
@export_multiline var shelter_exit_title: String = "REFUGIO DESPEJADO\nCivil rescatada: %s\nAyuda civil: %d/10\nPulsa E para volver al menú"
@export var shelter_exit_ready: String = "Salir"
@export var shelter_exit_locked: String = "Salida bloqueada"
@export var shelter_state_on: String = "ON"
@export var shelter_state_off: String = "OFF"
@export var shelter_state_open: String = "ABIERTAS"
@export var shelter_state_closed: String = "CERRADAS"
@export var shelter_state_civilian_rescued: String = "Civil rescatada"
@export var shelter_previous_state: String = "Estado anterior del refugio:"
@export var shelter_hud: String = "FINAL THAW | Generador %s | Válvulas %s | Oxígeno %.0fs | Ayuda civil %d/10"

## Puzle de registros y cableado (Fase 1, sala de control)
@export_group("Control Room Puzzle")
@export var cr_log_before_title: String = "Mantenimiento 14/06"
@export var cr_log_before_body: String = "Compuerta este: alimentación por el circuito ámbar. Revisión de contactos sin incidencias."
@export var cr_log_after_title: String = "Revisión posterior al incidente"
@export var cr_log_after_body: String = "Circuito ámbar fuera de servicio: fusible quemado tras la inundación. Compuerta este reencaminada por el circuito verde."
@export var cr_breaker_a_response: String = "La luz de la compuerta se enciende, pero el mecanismo no responde."
@export var cr_breaker_b_response: String = "Salta una chispa. El fusible de este ramal está quemado."
@export var cr_breaker_b_cooldown: String = "El cuadro todavía está caliente. Espera unos segundos."
@export var cr_breaker_c_response: String = "Contactos cerrados. La compuerta tiene presión."
@export var cr_gate_locked: String = "La compuerta está bloqueada. No hay presión en el mecanismo."
@export var cr_gate_open_prompt: String = "Abrir compuerta"
@export var cr_prompt_read_log: String = "Leer registro"
@export var cr_prompt_use_breaker: String = "Accionar cuadro"
@export var cr_trace_a: String = "Luminaria"
@export var cr_trace_b: String = "Bomba de achique"
@export var cr_trace_c: String = "Compuerta este"
@export var cr_hint_level_1: String = "Compara las fechas de los dos registros. Escanea cerca de los cuadros para ver adónde va cada cable."
@export var cr_hint_level_2: String = "El cuadro C alimenta la compuerta este."
@export var cr_objective_start: String = "OBJETIVO  /  Abre la compuerta este"
@export var cr_objective_done: String = "SALA SUPERADA  /  La compuerta está abierta"
@export var cr_hint_button: String = "Pista"
