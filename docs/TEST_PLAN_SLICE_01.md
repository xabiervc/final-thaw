# Plan de pruebas - Vertical Slice 01: "Flooded Shelter 2.5D"

**Objetivo:** validar que la demo es jugable de principio a fin, que las decisiones tienen peso y que no hay bloqueos críticos.

**Rama:** `feat/godot-vertical-slice`  
**Versión Godot:** 4.4+  
**Responsable de QA:** [nombre]  
**Fecha de prueba:** [fecha]

---

## Prueba 0: Preparación del entorno

**Pasos:**

1. Clonar el repositorio y cambiar a `feat/godot-vertical-slice`.
2. Abrir Godot 4.4+.
3. Importar el proyecto desde `project.godot`.
4. Abrir la consola de depuración (Debugger → Output).

**Resultado esperado:**

- Proyecto importa sin errores.
- No hay mensajes rojos en la consola al abrir.

**Notas / Bugs:**

```
[Escribir aquí cualquier error o advertencia relevante]
```

---

## Prueba 1: Arranque limpio

**Pasos:**

1. Ejecutar la escena `scenes/ui/main_menu.tscn`.
2. Observar la consola durante 10 segundos.
3. Comprobar que el menú se ve completo (título, texto, botón Start, botones ES/EN).

**Resultado esperado:**

- Menú carga sin errores de scripts.
- Textos visibles y legibles.
- Botones reactivos.

**Notas / Bugs:**

```
[]
```

---

## Prueba 2: Recorrido feliz (happy path)

**Objetivo:** completar la demo siguiendo el camino previsto.

**Pasos:**

1. Pulsar "Start Demo".
2. Mover a Elena hacia la consola de energía.
3. Interactuar con la consola.
4. Ir a la sala de válvulas.
5. Abrir las dos válvulas.
6. Ir a la sala de rescate.
7. Decidir si rescatar o no a la civil.
8. Alcanzar la zona de victoria (junto a la compuerta de salida).
9. Esperar a que aparezca la pantalla de fin de demo.

**Resultado esperado:**

- Elena se mueve y salta sin atravesar paredes.
- La interacción con la consola cambia el estado de la energía.
- Las válvulas pueden abrirse y afectan al estado del refugio.
- La civil puede ser rescatada o ignorada.
- La zona de victoria dispara `demo_end` con un resumen coherente.

**Notas / Bugs:**

```
[]
```

---

## Prueba 3: Comportamiento adverso

**Objetivo:** comprobar que el juego no se rompe con comportamientos inesperados.

**Escenarios:**

1. **No interactuar:**
   - No tocar nada, solo esperar.
   - Resultado esperado: el oxígeno baja y llega un final (derrota o timeout).

2. **Interactuar dos veces:**
   - Pulsar interactuar dos veces seguidas en la consola y en una válvula.
   - Resultado esperado: no hay error, el estado no se corrompe.

3. **Alejarse de Elena:**
   - Si es posible, salirse del camino previsto o intentar atravesar límites.
   - Resultado esperado: colisiones funcionan, no se puede salir del escenario.

4. **Zonas peligrosas:**
   - Entrar en zonas con agua o marcadas como peligrosas.
   - Resultado esperado: el juego responde (más drenaje de oxígeno, mensaje, etc.).

5. **Reiniciar durante la partida:**
   - Volver al menú o recargar escena en mitad del nivel.
   - Resultado esperado: se puede reiniciar sin estado corrupto.

6. **Cambiar idioma durante la demo:**
   - Si es posible, cambiar ES/EN en mitad de la partida.
   - Resultado esperado: los textos cambian o al menos no hay crash.

**Notas / Bugs:**

```
[]
```

---

## Prueba 4: Decisiones y consecuencias

**Objetivo:** validar que las elecciones del jugador modifican el estado y el final.

**Escenarios:**

1. **Rescatar a la civil:**
   - Completar la demo rescatando a la civil.
   - Anotar el texto de `demo_end`.

2. **No rescatar a la civil:**
   - Completar la demo sin rescatar a la civil.
   - Anotar el texto de `demo_end`.

3. **Activar energía vs ignorarla:**
   - Hacer una partida activando la energía y otra sin activarla.
   - Observar diferencias en luces, oxígeno o texto final.

4. **Válvulas abiertas vs cerradas:**
   - Completar una partida abriendo las dos válvulas y otra sin abrirlas.
   - Observar diferencias en el entorno y en el resumen final.

**Resultado esperado:**

- Los finales son claramente distintos según las decisiones.
- El jugador puede explicar qué cambió y por qué.

**Notas / Bugs:**

```
[]
```

---

## Prueba 5: Accesibilidad básica

**Objetivo:** comprobar que la demo es jugable con distintas configuraciones.

**Configuraciones a probar:**

1. **Solo teclado:**
   - Jugar toda la demo sin usar mando.

2. **Solo mando:**
   - Jugar toda la demo sin usar teclado.

3. **Texto ampliado / contraste:**
   - Si existe opción, aumentar tamaño de texto o cambiar contraste.
   - Comprobar legibilidad del HUD y menús.

4. **Audio desactivado:**
   - Bajar volumen a cero.
   - Comprobar que la demo sigue siendo comprensible (HUD, textos, señales visuales).

5. **Movimiento reducido:**
   - Si hay opción de reducir movimiento o cámara, probarla.
   - Comprobar que no rompe la jugabilidad.

**Notas / Bugs:**

```
[]
```

---

## Prueba 6: Rendimiento y estabilidad

**Objetivo:** confirmar que la demo mantiene un framerate aceptable y no crashea.

**Pasos:**

1. Ejecutar la demo en el hardware objetivo (o el más modesto disponible).
2. Jugar el recorrido completo.
3. Observar caídas de FPS, tirones o congelamientos.

**Resultado esperado:**

- Framerate estable (objetivo: [X] FPS).
- Sin congelamientos ni cierres inesperados.

**Notas / Bugs:**

```
[]
```

---

## Resumen de la sesión

**Estado general:** [Aprobado / Aprobado con condiciones / No aprobado]

**Principales problemas encontrados:**

```
1.
2.
3.
```

**Recomendaciones:**

```
- 
- 
- 
```

**Próxima fecha de revisión:** [fecha]
