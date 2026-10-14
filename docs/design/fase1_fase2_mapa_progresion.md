# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v0.7)

**Estado:** diseño funcional cerrado para el primer slice; validación de escena y jugabilidad pendiente.  
**Autoridad de experiencia:** FASE1_FUNCTIONAL_SPEC.md v1.0.  
**Autoridad espacial:** FASE1_SPATIAL_GRAPH.md v0.5 y FASE1_GREYBOX_SPEC.md v1.2.  
**Autoridad eléctrica:** FASE1_LOGIC_CONTRACT.md.  
**Implementación inicial pendiente de ejecutar:** `scenes/prototypes/phase1_canonical_greybox.tscn`; criterios de comprobación en `FASE1_CANONICAL_BUILD.md`.

## 1. Intención

- **Fase 1 — The Ghost Protocol:** Elena investiga una instalación, detecta una discrepancia física en la distribución del ensayo, configura el circuito de forma segura y consulta un registro contradictorio.
- **Fase 2 — Containment:** al salir por G, el relé de salida sincroniza la auditoría del uso de mantenimiento y Helix activa una unidad de recuperación. Elena debe escapar usando movimiento, sigilo, rutas y línea de visión.
- La experiencia conectada es **comprender, obtener evidencia y sufrir la consecuencia de haber intervenido en el sistema**.
- No se fija un número arbitrario de habitaciones. Se conservan entrada, máquina central, foso, circuito, archivo, vestíbulo de salida y exterior.

## 2. Recorrido definitivo

Entrada → ruta sur → explanada → escalera fija → foso → activar mantenimiento → vuelta por escalera fija → plataforma elevadora → pasarela E → archivo F → vestíbulo G → exterior H.

La variante B (subir antes de visitar el foso) queda retirada del slice. Mantenimiento inicia apagado; la plataforma depende de él y no hay rampa paralela. Esta dependencia hace que el jugador visite el foso sin obligarlo a leer cada pista. La escalera del foso sigue siendo funcional sin electricidad. Las compuertas fijas de los dos rellanos se interbloquean con el estado del elevador: solo se abre la del rellano donde está acoplado el deck y ambas permanecen cerradas durante el movimiento.

## 3. Sectores funcionales

| Sector | Función cerrada | Estado de progresión |
|---|---|---|
| A. Acceso | Presentar destino y acceso roto | Conduce a B |
| B. Observación | Mostrar la instalación y la máquina antes de resolverla | Conduce a C |
| C. Nave de ensayo | Ubicar la máquina y sus anomalías | La maquinaria no puede arrancar en este slice |
| D. Servicios y foso | Ver esquema previsto, puente A→T manipulado y mando de mantenimiento | Activar mantenimiento habilita luces de servicio y plataforma |
| E. Distribución y control | Permitir ensayar hipótesis, diagnosticar disparo y rearmar | Se aplica literalmente el contrato lógico |
| F. Archivo | Mostrar suministro estable/no disponible y permitir consulta condicionada | Conocimiento adquirido persiste en la sesión, no en el guardado permanente |
| G. Vestíbulo/salida | Desbloquear salida desde la cabina y cruzar a H | El relé sincroniza auditoría de servicio al salir |
| H. Primer encuentro exterior | Poner a prueba detección, rutas, cobertura y ruptura de línea de visión | Reutilizar el prototipo de persecución, después de ejecutar sus pruebas |

## 4. Circuito y evidencia

- Estado inicial: mantenimiento OFF, selector ENSAYO, ensayo conectado, protección disponible, sin último disparo.
- Orden recomendado: aislar ENSAYO, seleccionar ARCHIVO y comprobar diagnóstico.
- Si se selecciona ARCHIVO con ensayo conectado, la protección dispara y registra DEMANDA_SIMULTANEA. El jugador puede recuperarse aislando y rearmando una vez desaparece el fallo.
- Cambiar selector o aislador nunca rearma implícitamente. Diagnóstico y last_trip permanecen separados.
- El indicador de E muestra señales de estado, no instrucciones. La consola completa de diagnóstico permanece accesible siempre.
- El indicador local de F solo muestra SUMINISTRO ESTABLE / NO DISPONIBLE. La consulta requiere archivo estable.
- El registro consultado contradice el acta oficial: el acta declara alimentación exclusiva a T, mientras la telemetría registra corriente simultánea en A y T.
- Consulta no es extracción, no concede autorización de extracción y no cambia el formato de guardado.

## 5. Transición narrativa cerrada

El interruptor de mantenimiento registra SERVICE_OVERRIDE local. Si Elena consulta el archivo, se añade RESTRICTED_RECORD_READ. Al cruzar la compuerta exterior G, el controlador de salida sincroniza el evento; Helix recibe el registro y activa Containment. La protagonista ve una señal de sincronización/alarma al salir. La unidad de recuperación en H empieza en patrulla y solo adquiere conocimiento de Elena según las reglas normales de visión, línea de visión y ruido del prototipo.

La consulta no activa por sí misma la persecución ni representa una extracción. Si se omite el registro, salir sigue siendo posible y el evento SERVICE_OVERRIDE sigue justificando Containment; la sesión simplemente no ha adquirido esa evidencia. Esto evita convertir las pistas en llaves técnicas del circuito.

## 6. Alcance de fase y orden de trabajo

1. Implementar geometría fija y plataforma, incluyendo el fallo seguro.
2. Implementar contrato eléctrico y pruebas automatizadas aisladas.
3. Añadir selector, aislador, estado E, rearme y terminal de diagnóstico.
4. Añadir consola de consulta, indicador F y bandera de conocimiento de sesión.
5. Añadir puertas G, registro de auditoría y transición a H.
6. Ejecutar pruebas de Fase 1 y regresión de Fase 0; corregir antes de integrar la persecución.
7. Ejecutar y validar por separado el prototipo de persecución v2 antes de conectarlo a H.

## 7. Criterio de cierre

La fase no se acepta hasta que las pruebas de circuito, plataforma, interacciones, salida, colisiones, cámara y flujo se hayan ejecutado y registrado. Un test de referencia o un documento cerrado no acredita validación de escena. No se modifican contratos de guardado, autoloads, acciones de entrada, rutas de recursos ni renderer.
