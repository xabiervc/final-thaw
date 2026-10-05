# Release Notes - Vertical Slice 01: "Flooded Shelter 2.5D"

**Rama:** `feat/godot-vertical-slice`  
**Fecha:** 2026-10-05  
**Responsable:** [Tu nombre / equipo]

## ¿Qué es esto?

Este es el primer vertical slice jugable de *Final Thaw*. Controlas a Elena en un refugio inundado, gestionas oxígeno, tomas decisiones (energía, válvulas, rescate) y ves las consecuencias en una pantalla final. El esqueleto técnico y narrativo está completo; ahora toca convertirlo en una demo presentable.

## Qué ha cambiado

### Nuevo
- **Menú principal** con contexto narrativo y selector de idioma ES/EN.
- **Nivel "Flooded Shelter 2.5D"**:
  - Movimiento lateral y salto.
  - Oxígeno que baja con el tiempo.
  - Tres salas: energía, válvulas, rescate.
  - Civil atrapada con decisión de rescate.
  - Zona de victoria y pantalla final con resumen.
- **Sistemas**:
  - `GameStateManager`: guarda decisiones y preferencia de idioma.
  - `NarrativeTextManager`: textos centralizados en `data/narrative_text_*.tres`.
  - Soporte bilingüe ES/EN.
- **Documentación**:
  - `SETUP_FLOODED_SHELTER.md`: cómo montar y probar en Godot.
  - `PRESENTATION_ROADMAP.md`: tareas para pulir la demo.
  - `NARRATIVE_SCRIPT.md`: guion de textos y tono.
  - `TRANSLATIONS.md`: cómo añadir más idiomas.
  - `PROJECT_STATUS.md`: estado global y próximos pasos.
  - `RELEASE_NOTES_SLICE_01.md`: este documento.

### Eliminado
- `scenes/levels/test_room.tscn` (graybox antiguo).

## Cómo probarlo

1. Cambia a la rama `feat/godot-vertical-slice`.
2. Abre el proyecto en Godot 4.4+.
3. Sigue `docs/SETUP_FLOODED_SHELTER.md` para:
   - Asignar nodos en `ShelterController`.
   - Configurar colisiones y capas.
   - Probar movimiento, interacción, oxígeno y win/lose.
4. Usa los botones **ES/EN** en el menú para cambiar de idioma.

## Qué falta para una demo presentable

### Arte (prioridad alta)
- [ ] Sprites y animaciones de Elena (idle, walk, jump, interact).
- [ ] Sprite y animaciones de la civil (trapped, rescued).
- [ ] Arte de entorno: fondos parallax, suelo, paredes, tuberías, luces.
- [ ] Sprites de objetos: consola, válvulas, compuerta, luces.

### Iluminación y atmósfera
- [ ] `CanvasModulate` frío (azul-gris).
- [ ] `PointLight2D` en luces de emergencia, Aster y objetos.
- [ ] Ajuste de sombras y contraste.

### Efectos visuales
- [ ] Lluvia y goteo (`GPUParticles2D`).
- [ ] Vapor/niebla en zonas inundadas.
- [ ] Destellos en interacciones.

### Audio
- [ ] Ambiente: lluvia, goteo, zumbido de maquinaria.
- [ ] SFX: pasos, interacciones, compuerta, aviso de oxígeno bajo.
- [ ] Música ambiental tensa.

### UI y pulido
- [ ] Barra de oxígeno visual (no solo texto).
- [ ] Mejoras de legibilidad y espaciado en HUD.
- [ ] Ajuste de ritmo y dificultad.

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

## Llamada a la acción por rol

### Diseño
- Revisar ritmo, dificultad y claridad de objetivos.
- Proponer ajustes a valores de oxígeno, velocidad y puzles.

### Arte
- Empezar por Elena y la civil (son lo primero que ve el jugador).
- Definir paleta y estilo para el refugio (frío, industrial, húmedo).

### Programación
- Integrar assets según lleguen.
- Añadir animaciones, partículas y ajustes de cámara.
- Preparar base para el slice de Marcus.

### Audio
- Proponer referencias de ambiente y música.
- Crear SFX básicos para interacciones y oxígeno bajo.

## Cómo trabajar sobre esta base

1. **No rompas el slice:** si haces cambios grandes, prueba que el flujo menú → refugio → fin sigue funcionando.
2. **Usa la documentación:** `SETUP_FLOODED_SHELTER.md` y `PRESENTATION_ROADMAP.md` son tu guía principal.
3. **Comunica cambios:** si tocas gameplay, oxígeno o decisiones, avisa al equipo.
4. **Prioriza lo visible:** arte, luz y VFX tienen más impacto inmediato que refactorizaciones internas.

## Resumen

Este slice es la **primera versión jugable** de Final Thaw. Ya se entiende la premisa, las mecánicas clave y el tono narrativo. El siguiente paso es **hacerlo visual y sonoramente presentable**, para que un jugador nuevo sienta la atmósfera de un mundo en colapso climático y el peso de las decisiones de Elena.
