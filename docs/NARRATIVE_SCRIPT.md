# Guion narrativo para la demo "Flooded Shelter"

Este documento contiene el texto concreto que aparece en menú, HUD, interacciones y pantalla final.

## 1. Menú principal

### Título
```
Final Thaw
Vertical Slice
```

### Texto de contexto (pantalla de menú)
```
Año 2047. El colapso climático ha sumido a las ciudades en caos.
Las tormentas no se detienen. Los refugios se inundan. La gente espera
que alguien tome decisiones imposibles.

Elena Vast, científica del proyecto Aster, y Marcus Reyes, oficial de
seguridad, deben cooperar para salvar lo que queda de la humanidad.

En esta demo, controlarás a Elena en un refugio de emergencia inundado.
Cada decisión afecta a quienes dependen de ti.
```

### Texto adicional si hay decisiones previas (leído de GameStateManager)
```
Estado previo:
- Refugio: energía restaurada.
- Refugio: válvulas abiertas.
- Refugio: civil rescatada.
```

### Botón
```
Iniciar Demo
```

## 2. HUD en el refugio

### Oxígeno (label o barra)
```
Oxígeno: 100%
```
Cuando baja del 30%:
```
Oxígeno: 25%  [en rojo o parpadeando]
```

### Objetivo (cambia según el progreso)

**Inicio (sin energía):**
```
Objetivo: Activa el generador para restaurar la energía.
```

**Energía activada, válvulas cerradas:**
```
Objetivo: Abre las válvulas para drenar el agua y continuar.
```

**Válvulas abiertas, civil atrapada:**
```
Objetivo: Decide si rescatas a la civil antes de alcanzar la salida.
```

**Civil rescatada o ignorada, salida disponible:**
```
Objetivo: Alcanza la salida del refugio.
```

### Estado de la civil
```
Civil: Atrapada
```
Cuando es rescatada:
```
Civil: Rescatada
```
Si muere (en futuras versiones):
```
Civil: Fallecida
```

## 3. Texto de interacción (burbujas o prompts)

### Consola de energía
```
[Consola de emergencia]
Activar generador
```
Después de activarla:
```
[Consola de emergencia]
Generador en funcionamiento
```

### Válvulas
```
[Válvula de drenaje]
Abrir válvula
```
Después de abrirla:
```
[Válvula de drenaje]
Válvula abierta
```

### Civil atrapada
```
[Civil atrapada]
Rescatar
```
Después de rescatarla:
```
[Civil atrapada]
A salvo
```

### Compuerta de salida
```
[Compuerta de salida]
[Abierta / Cerrada]
```

## 4. Frases de la civil (opcional, al rescatar)

Al ser rescatada, puede decir una de estas líneas (en orden aleatorio o fijo):

```
"Gracias... pensé que no saldría de aquí."
"No creí que volviera a ver a alguien."
"Mi familia está en el sector norte... ¿podrás llevarles ayuda?"
"No tengo fuerzas para seguir. Gracias por intentarlo."
```

## 5. Pantalla final de demo

### Título
Si Elena sobrevive:
```
Demo completada
```
Si Elena muere (oxígeno a cero):
```
Demo fallida
```

### Resumen (siempre se muestra)
```
Elena: Sobrevivió
Civil: Rescatada
```
o
```
Elena: Sobrevivió
Civil: No rescatada
```
o
```
Elena: No sobrevivió
Civil: Estado desconocido
```

### Líneas adicionales según decisiones

Si se restauró la energía:
```
Refugio: energía restaurada.
Algunos sistemas de emergencia volvieron a funcionar.
```

Si se abrieron las válvulas:
```
Refugio: válvulas abiertas.
El agua comenzó a drenarse, pero demasiado tarde para algunos.
```

Si se rescató a la civil:
```
Refugio: civil rescatada.
Una vida más entre las que dependen de tus decisiones.
```

Si no se rescató:
```
Refugio: civil no rescatada.
No todos pueden ser salvados. Eso también es una decisión.
```

### Botones
```
Volver al menú
Reiniciar demo
```

## 6. Tono y estilo

- Frases cortas, directas y sobrias.
- Evitar dramatismo excesivo; dejar que la situación hable por sí misma.
- Enfocar en consecuencias, no en juicios morales explícitos.
- Mantener coherencia con un mundo cansado, no espectacular.

## 7. Uso en código

Estos textos pueden integrarse en:

- `main_menu.gd`: título, contexto y estado previo.
- `demo_hud.gd`: objetivos y estado de la civil.
- `interactable.gd` o scripts de objetos: texto de interacción.
- `demo_end.gd`: resumen final y líneas de consecuencia.

Se recomienda centralizarlos en un recurso `DialogueResource` o script singleton `NarrativeText` para facilitar traducción y ajustes.
