# Elena Vast — guía de producción del personaje

## Dirección aprobada

Científica de campo de Final Thaw, con tecnología de futuro cercano y equipo práctico. Mantener la silueta y paleta frías del concepto: abrigo azul petróleo, equipo de campo compacto y un Aster de luz cian discreta. Evitar armadura, armas o adornos tecnológicos exagerados. El GDD establece para Elena azules fríos, cian y blancos clínicos.

## Nota de producción

La hoja conceptual sirve como referencia visual, no como modelo 3D ni como sprites listos para producción. Antes del modelado, separar claramente frente, perfil y tres cuartos y corregir proporciones/detalles en una lámina ortográfica limpia; las imágenes generadas pueden tener inconsistencias entre vistas.

## Pipeline recomendado

1. **Aprobación del diseño:** fijar proporciones, rasgos, ropa, mochila y ubicación del Aster. Crear una hoja con frente, perfil, espalda y tres cuartos, manteniendo rasgos idénticos.
2. **Blockout en Blender:** modelar formas grandes y validar la silueta a la escala de juego. Usar materiales simples y paleta plana; no empezar por detalles ni texturas.
3. **Prueba en Godot:** importar el blockout y colocarlo en la escena real del refugio. Ajustar cámara, escala, iluminación y lectura contra el fondo antes de detallar.
4. **Modelo final:** retopología sencilla para deformación, materiales estilizados y geometría ligera. Mantener rasgos y equipo distinguibles en la resolución objetivo.
5. **Rig:** esqueleto humano sencillo con huesos para torso, cabeza, brazos, manos, piernas y pies. Añadir controles faciales solo si la cámara los necesita.
6. **Animación inicial:** `idle`, `walk`, `interact`, `hurt` y una reacción breve. Validar primero el ciclo de caminar y la pose de interacción en Godot.
7. **Exportación:** exportar como `.glb`/glTF desde Blender, con armature y animaciones seleccionadas. Godot recomienda glTF para escenas 3D; mantener la escena Blender fuente en el proyecto de arte y el `.glb` como entrega importable.
8. **Integración:** reproducir animaciones desde el controlador de Elena y probar las colisiones por separado de la malla visual.
9. **Beat ’em up 2D:** reutilizar el mismo modelo/rig para renderizar sprites laterales si se necesitan; validar cámara y estilo antes de producir todas las orientaciones.
10. **Web app:** hacer exportación de prueba temprana con modelo, texturas y animaciones reales; optimizar geometría, materiales, resolución de texturas y tamaño de descarga.

## Entregables por hito

- `01_design/`: hoja conceptual limpia y paleta.
- `02_blender/elena_blockout.blend`: blockout aprobado.
- `03_blender/elena_rigged.blend`: modelo y rig.
- `04_export/elena.glb`: modelo final con animaciones.
- `05_godot/`: escena del personaje, controlador y prueba de cámara.

## Criterios de aprobación

- Elena se reconoce en silueta y a escala de gameplay.
- Abrigo, mochila y Aster no se confunden entre sí.
- El ciclo de andar no produce deformaciones evidentes.
- Las animaciones importan y se reproducen en Godot.
- La apariencia funciona en navegador y en los dispositivos objetivo.
