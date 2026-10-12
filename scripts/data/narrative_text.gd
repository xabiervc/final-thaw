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
