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

## HUD
@export_group("HUD")
@export var hud_oxygen_label: String = "Oxígeno: %d%%"
@export var hud_oxygen_low_threshold: float = 30.0
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
