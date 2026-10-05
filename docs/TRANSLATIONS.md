# Cómo añadir traducciones (inglés y otros idiomas)

Este documento explica cómo preparar el proyecto para soportar varios idiomas usando el sistema de narrativa actual.

## 1. Estructura actual

Todos los textos en español viven en:

```
data/narrative_text.tres
```

Con el singleton:

```
scripts/managers/narrative_text_manager.gd
```

## 2. Crear recursos por idioma

Para cada idioma, crea una copia del recurso con los textos traducidos:

```
data/
├── narrative_text_es.tres    # Español (actual)
├── narrative_text_en.tres    # Inglés
└── narrative_text_fr.tres    # Francés (futuro)
```

Pasos:

1. En Godot, haz clic derecho sobre `narrative_text.tres` → "Guardar como...".
2. Nómbralo `narrative_text_en.tres` (o el código de idioma que corresponda).
3. Abre el nuevo recurso y traduce todos los campos de texto.
4. Repite para cada idioma.

## 3. Cambiar el idioma en tiempo de ejecución

Modifica `NarrativeTextManager` para cargar el recurso según el idioma:

```gdscript
static func set_locale(locale_code: String) -> void:
	var path = "res://data/narrative_text_%s.tres" % locale_code
	if not ResourceLoader.exists(path):
		path = "res://data/narrative_text_es.tres"  # fallback
	texts = ResourceLoader.load(path) as NarrativeText
```

Llama a `set_locale("en")` o `set_locale("es")` al iniciar el juego, según la configuración del usuario o del sistema.

## 4. Ejemplo de textos en inglés

A continuación, un ejemplo de cómo podrían verse algunos campos en `narrative_text_en.tres`:

```gdscript
menu_title = "Final Thaw\nVertical Slice"

menu_context = """
Year 2047. Climate collapse has plunged cities into chaos.
The storms do not stop. Shelters flood. People wait for someone
to make impossible decisions.

Elena Vast, scientist of the Aster project, and Marcus Reyes,
security officer, must cooperate to save what remains of humanity.

In this demo, you will control Elena in a flooded emergency shelter.
Every decision affects those who depend on you.
"""

menu_start_button = "Start Demo"

hud_oxygen_label = "Oxygen: %d%%"
hud_civilian_trapped = "Civilian: Trapped"
hud_civilian_rescued = "Civilian: Rescued"
hud_civilian_dead = "Civilian: Deceased"

hud_objective_start = "Objective: Activate the generator to restore power."
hud_objective_power_on = "Objective: Open the valves to drain the water and continue."
hud_objective_valves_open = "Objective: Decide whether to rescue the civilian before reaching the exit."
hud_objective_exit = "Objective: Reach the shelter exit."

interact_power_console_off = "Activate generator"
interact_power_console_on = "Generator running"
interact_valve_closed = "Open valve"
interact_valve_open = "Valve open"
interact_civilian_trapped = "Rescue"
interact_civilian_rescued = "Safe"

civilian_rescue_lines = [
	"Thank you... I thought I wouldn't make it out of here.",
	"I didn't think I'd see anyone again.",
	"My family is in the northern sector... can you bring them help?",
	"I don't have the strength to go on. Thanks for trying."
]

end_title_success = "Demo Complete"
end_title_failure = "Demo Failed"
end_elena_alive = "Elena: Survived"
end_elena_dead = "Elena: Did not survive"
end_civilian_unknown = "Civilian: Status unknown"

end_power_restored = """
Shelter: power restored.
Some emergency systems are back online.
"""

end_valves_opened = """
Shelter: valves opened.
The water began to drain, but too late for some.
"""

end_civilian_rescued = """
Shelter: civilian rescued.
One more life among those who depend on your decisions.
"""

end_civilian_not_rescued = """
Shelter: civilian not rescued.
Not everyone can be saved. That is also a decision.
"""

end_button_menu = "Back to Menu"
end_button_restart = "Restart Demo"
```

## 5. Integración con Godot

Godot tiene un sistema de traducción nativo (`TranslationServer` y archivos `.csv` o `.gettext`). Este enfoque con recursos es más simple y suficiente para una demo pequeña. Si el proyecto crece, puedes migrar a ese sistema más adelante.

Por ahora:

- Mantén un recurso `narrative_text_<locale>.tres` por idioma.
- Usa `NarrativeTextManager.set_locale()` al iniciar.
- Todo el código sigue llamando a `NarrativeTextManager.get_*()` sin cambios.

## 6. Flujo recomendado

1. Terminar y estabilizar todos los textos en español.
2. Crear `narrative_text_en.tres` y traducir.
3. Añadir un selector de idioma simple en el menú (opcional).
4. Probar ambas versiones y ajustar longitud de textos en UI.

## 7. Notas de estilo

- Mantener frases cortas y sobrias en todos los idiomas.
- Evitar expresiones demasiado idiomáticas que no se traduzcan bien.
- Revisar que los textos quepan en los labels de la UI en cada idioma.
