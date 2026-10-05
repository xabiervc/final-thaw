# Estado del proyecto - Final Thaw

## Vertical Slice: "Flooded Shelter 2.5D" (Elena)

### Estado
- **Rama:** `feat/godot-vertical-slice`
- **Estado:** Esqueleto funcional completo, pendiente de arte y pulido visual/sonoro.

### Qué hay implementado

#### Gameplay
- Movimiento lateral de Elena (izquierda/derecha, salto).
- Sistema de oxígeno que disminuye con el tiempo.
- Interacción con objetos (tecla `E`).
- Tres salas:
  - Sala de energía: consola para activar generador.
  - Sala de válvulas: dos válvulas para drenar agua.
  - Sala de rescate: civil atrapada y compuerta de salida.
- Zona de victoria al alcanzar la salida.
- Pantalla de fin de demo con resumen de decisiones.

#### Estructura de escenas
- `scenes/ui/main_menu.tscn`: menú con contexto narrativo y selector de idioma ES/EN.
- `scenes/levels/flooded_shelter_2_5d.tscn`: nivel principal del slice.
- `scenes/ui/demo_hud.tscn`: HUD con oxígeno, objetivo y estado de la civil.
- `scenes/ui/demo_end.tscn`: pantalla final con resumen.
- `scenes/props/*.tscn`: consola, válvulas, compuerta y luz.

#### Sistemas
- `GameStateManager`: persiste decisiones (energía, válvulas, civil) y preferencia de idioma.
- `NarrativeTextManager`: textos centralizados en `data/narrative_text_*.tres`.
- Soporte bilingüe ES/EN con selector en menú.

#### Documentación
- `docs/SETUP_FLOODED_SHELTER.md`: instrucciones para montar y probar en Godot.
- `docs/PRESENTATION_ROADMAP.md`: lista de tareas para una demo presentable (assets, luz, VFX, audio).
- `docs/NARRATIVE_SCRIPT.md`: guion de textos y tono narrativo.
- `docs/TRANSLATIONS.md`: guía para añadir más idiomas.

### Qué falta para una demo presentable

#### Assets y arte
- Sprites y animaciones de Elena (idle, walk, jump, interact).
- Sprite y animaciones de la civil (atrapada, rescatada).
- Arte de entorno: fondos parallax, suelo, paredes, tuberías, luces.
- Sprites para objetos: consola, válvulas, compuerta, luces.

#### Iluminación y atmósfera
- `CanvasModulate` para tono frío.
- `PointLight2D` en luces de emergencia, Aster y objetos.
- Ajuste de sombras y contraste.

#### Efectos visuales
- Lluvia y goteo (`GPUParticles2D`).
- Vapor/niebla en zonas inundadas.
- Destellos en interacciones.

#### Audio
- Ambiente: lluvia, goteo, zumbido de maquinaria.
- SFX: pasos, interacciones, compuerta, aviso de oxígeno bajo.
- Música ambiental tensa.

#### UI y pulido
- Barra de oxígeno visual (no solo texto).
- Mejoras de legibilidad y espaciado en HUD.
- Ajuste de ritmo y dificultad.

## Próximos slices

### Marcus - Beat 'Em Up 2D
- Arena con movimiento en X/Y (estilo Streets of Rage).
- Combo básico, golpe fuerte, esquiva.
- Enemigos básicos con hitbox/hurtbox.
- Objeto ambiental arrojadizo.
- Consecuencias que afectan a `civilian_aid`.

### Integración
- Transiciones entre slices con diálogo y consecuencias.
- Sistema de guardado global y árbol de decisiones.

## Cómo probar el slice actual

1. Cambia a la rama `feat/godot-vertical-slice`.
2. Abre el proyecto en Godot 4.4+.
3. Sigue las instrucciones de `docs/SETUP_FLOODED_SHELTER.md` para asignar nodos y probar.
4. Usa el selector ES/EN en el menú para cambiar de idioma.

## Resumen

El vertical slice de Elena está **funcionalmente completo** a nivel de diseño y código. El siguiente gran bloque de trabajo es **arte, iluminación, VFX y audio** para convertir este esqueleto en una demo presentable, seguido del slice de combate de Marcus.
