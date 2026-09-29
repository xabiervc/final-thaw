# FINAL THAW — CLAUDE.md

## Visión del proyecto
Juego de acción-aventura isométrico para un solo jugador, construido en Godot 4.x. Alterna puzles ambientales (Elena Vast) y combate beat-'em-up (Marcus Reyes), con misiones conjuntas que requieren cooperación. Duración objetivo: 2.5–3.5 horas.

## Determinismo
- Física a 60 Hz (fixed timestep).
- Sin RNG oculto en IA de enemigos, estados de puzles, peligros, minijuegos ni finales.
- Si en el futuro se usa aleatoriedad, debe tener semilla explícita y guardada.

## Convenciones de nombres
- PascalCase para escenas (.tscn), clases y componentes.
- snake_case para variables y funciones en GDScript.
- Nombres de archivos en minúsculas con guiones: `elena_character.tscn`, `enemy_scavenger.gd`.

## Estructura de carpetas
- `scenes/` (ui, levels, characters, components, minigames)
- `scripts/` (autoload, characters, components)
- `assets/` (sprites, audio)
- `resources/` (configuración y datos)
- `docs/` (diseño, guion, biblia narrativa)
- `config/` (constantes de juego, decisiones, consecuencias)
- `data/` (personajes, localizaciones, facciones, objetos)
- `schemas/` (validación de contenido narrativo)
- `tests/` (continuidad, finales, coherencia)
- `tools/` (validación y generación de contenido)
- `exports/` (builds de lanzamiento)

## Flujo Git
- Un commit por fase completada.
- Mensajes de commit exactos según el prompt de fase.
- No mezclar fases en un mismo commit.

## Criterios de aceptación por fase
- Ejecutar la escena relevante y verificar que no hay errores en consola.
- Comprobar que los criterios de aceptación del prompt se cumplen.
- Documentar limitaciones conocidas antes de hacer commit.

## Límites de alcance
- No añadir mundo abierto, generación procedural, loot, monetización ni multijugador.
- No incorporar sistemas no solicitados en los prompts de fase.
- Mantener arte y sonido provisionales hasta la fase de pulido (Phase 16).

## Seguridad y guardado
- GameManager guarda en `user://savegame.json`.
- Manejar archivos corruptos o inexistentes sin crash.
- Validar estados antes de escribir en disco.

## Accesibilidad
- Remapeo de controles o documentación clara.
- Opción de tamaño de texto (normal/grande).
- Reducción de cámara temblorosa y efectos intensos.
- Indicadores no basados solo en color para puzles.

## Estilo narrativo
- Tono serio pero esperanzado. Evitar catastrofismo gratuito.
- Diálogos concisos, creíbles y con propósito.
- Consecuencias visibles y comprensibles para el jugador.
- Los 3 finales deben sentirse merecidos según las decisiones del jugador.
