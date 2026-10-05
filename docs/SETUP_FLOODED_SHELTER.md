# Cómo montar el slice "Flooded Shelter 2.5D" en Godot

Este documento explica paso a paso cómo abrir el proyecto y dejar funcional la demo de Elena en el refugio inundado.

## 1. Abrir el proyecto

1. Abre Godot 4.4 o superior.
2. Importa el proyecto desde la carpeta `final-thaw`.
3. Asegúrate de que la rama activa es `feat/godot-vertical-slice`.

## 2. Asignar nodos en ShelterController

1. Abre `scenes/levels/flooded_shelter_2_5d.tscn`.
2. Selecciona el nodo `ShelterController`.
3. En el inspector, asigna las siguientes propiedades:

- `Elena`: arrastra el nodo `Elena` desde el árbol de la escena.
- `Civilian`: arrastra el nodo `Civilian`.
- `Power Console`: arrastra el nodo `PowerRoom/PowerConsole`.
- `Valve Station Left`: arrastra `ValveRoom/ValveLeft`.
- `Valve Station Right`: arrastra `ValveRoom/ValveRight`.
- `Flood Gate Exit`: arrastra `RescueRoom/FloodGateExit`.

4. Guarda la escena.

## 3. Configurar colisiones y capas

1. Abre `scenes/levels/flooded_shelter_2_5d.tscn`.
2. Para cada objeto del entorno (suelo, paredes, plataformas):
   - Añade un `StaticBody2D` con `CollisionShape2D`.
   - Configura la capa de colisión como `world` (capa 1).
3. Para `Elena`:
   - Asegúrate de que su `CollisionShape2D` está en la capa `player` (capa 2).
   - En `InteractionArea`, configura:
     - `collision_layer`: `interactables` (capa 4).
     - `collision_mask`: `interactables` (capa 4).
4. Para los objetos interactivos (`PowerConsole`, `ValveLeft`, `ValveRight`):
   - Añade un `Area2D` o usa el nodo que ya tengan.
   - Configura:
     - `collision_layer`: `interactables` (capa 4).
     - `collision_mask`: `player` (capa 2).

## 4. Probar movimiento e interacción

1. Ejecuta la escena `flooded_shelter_2_5d.tscn` o inicia el proyecto desde `main_menu.tscn`.
2. Controles:
   - Moverse: `A` / `D` o flechas izquierda/derecha.
   - Saltar: `W` o espacio.
   - Interactuar: `E`.
3. Verifica:
   - Elena se mueve y salta.
   - El oxígeno baja con el tiempo y el HUD lo muestra.
   - Al interactuar con la consola, se restaura la energía.
   - Al abrir las dos válvulas, se drena el agua y se abre la compuerta.
   - Al rescatar a la civil, el HUD actualiza su estado.
   - Al llegar a la zona de victoria, aparece la pantalla de fin de demo.

## 5. Añadir arte provisional (opcional)

Para que la demo sea más presentable:

1. Añade sprites a:
   - `Elena/Sprite2D`
   - `Civilian` (Sprite2D o nodo similar)
   - `PowerConsole/Sprite2D`
   - `ValveLeft/Sprite2D`, `ValveRight/Sprite2D`
   - `FloodGateExit/Sprite2D`
   - `ShelterLight/Sprite2D` y `PointLight2D`
2. Añade texturas a los `Parallax2D`:
   - `Background`: fondo lejano del refugio.
   - `Midground`: tuberías, maquinaria, luces distantes.
   - `Foreground`: barandillas, cables, elementos cercanos.
3. Ajusta `z_index` para que los elementos se ordenen correctamente en profundidad.

## 6. Ajustes finales

1. Regula la velocidad de movimiento, salto y gravedad en `Elena` para que se sienta bien.
2. Ajusta `oxygen_drain_rate` para que el tiempo de la demo sea cómodo.
3. Si quieres que el estado persista entre sesiones, implementa guardado en disco en `GameStateManager`.

## 7. Siguientes pasos

- Añadir animaciones a Elena y la civil.
- Mejorar la iluminación con `PointLight2D` y `CanvasModulate`.
- Añadir partículas para lluvia, vapor y gotas.
- Integrar este slice con el menú y posibles siguientes niveles.
