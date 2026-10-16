# FINAL THAW — Fase 1: grafo espacial (v2.0 · rediseño ampliado)

**Estado:** propuesta espacial; requiere reconciliación con Godot. El grafo del nivel construido anteriormente está documentado en [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md). Este documento describe el objetivo nuevo, no el estado actual del runtime.

## 1. Modelo de navegación

La instalación se organiza en una espina por nivel y varios ramales de diferente importancia. La ruta crítica no es una secuencia de habitaciones con objetos obligatorios: el jugador puede descubrir espacios técnicos y el ascensor antes de desbloquearlos. Los ramales secundarios contienen contexto ambiental, oportunidades de observación y, en uno o dos casos, una ventaja opcional.

### P0 — Investigación
- **P0-CORRIDOR-ACCESS:** acceso arquitectónico antiguo al pasillo principal; no es el punto de entrada inicial de Elena. Etiqueta visible: «ACCESO AL PASILLO».
- **P0-ELENA-BREACH:** brecha o conducto de servicio por el que Elena entra; se colapsa después y bloquea físicamente el retorno. Etiqueta visible: «BRECHA DE ELENA — COLAPSADA TRAS ENTRAR».
- **P0-SEALED-CONNECTION:** puerta de seguridad que comunica con el segundo edificio, donde los antagonistas trabajan clandestinamente. Permanece cerrada hasta completar la progresión necesaria y es el umbral narrativo entre ambos edificios.
- **P0-AIRLOCK:** esclusa y vestíbulo de personal.
- **P0-LOCKERS:** vestuarios; espacio ambiental.
- **P0-SHIFT-ARCHIVE:** pizarra de turnos + tira de presión; pista necesaria para deducir el código del cajón.
- **P0-DISPATCH:** despacho con cajón cerrado; tras resolver la pista entrega SERVICE_KEY y INSULATED_BRIDGE.
- **P0-WAITING:** sala de espera opcional.
- **P0-REST:** descanso del personal, opcional.
- **P0-STORAGE:** almacén secundario, opcional.
- **P0-HALL:** nave central y columna Aster; hito de orientación, ascensor visible.
- **P0-INSTRUMENTS:** taller de instrumentos; contexto y posible ventaja opcional.
- **P0-SAMPLES:** lavado y muestras.
- **P0-LIFT:** vestíbulo del ascensor; inaccesible como transporte hasta restablecer energía.

### P−2 — Energía
- **B2-PUMPS:** cámara de achique y bombas.
- **B2-FILTERS:** tratamiento de agua.
- **B2-BATTERY:** baterías auxiliares.
- **B2-SUBSTATION:** puerta con llave; punto de conexión eléctrica.
- **B2-CABLE-GALLERY:** galería de cables.
- **B2-VENT:** ventilación, opcional.
- **B2-SPARES:** almacén de repuestos, opcional.
- **B2-SUMP:** foso de mantenimiento.
- **B2-FLOODED:** cuarto inundado, opcional/de atmósfera.
- **B2-DEAD-WORKSHOP:** taller muerto, ramal sin recompensa obligatoria.
- **B2-LIFT-MACHINERY:** maquinaria del ascensor.
- **B2-LIFT:** núcleo del ascensor.

### M +1,50 — Observación
- **M-GALLERY:** pasarela sobre la nave.
- **M-SAMPLE-LAB:** laboratorio de muestras.
- **M-INSTRUMENTS:** instrumentos de reserva.
- **M-CALIBRATION:** banco de calibración.
- **M-MEETING:** sala de reuniones.
- **M-ARCHIVE:** archivo secundario.
- **M-UPPER-WORKSHOP:** taller superior.
- **M-REST:** sala de pausa.
- **M-DUCTS:** ductos de servicio.
- **M-DARK-ANNEX:** anexo oscurecido, opcional.
- **M-LIFT:** conexión con el núcleo del ascensor.

### P+3 — Control
- **P3-SECURITY:** seguridad y monitorización.
- **P3-ARCHIVE:** archivo restringido.
- **P3-CONTROL:** control de instalaciones.
- **P3-SEALED-LAB:** laboratorio sellado; contexto, no llave obligatoria.
- **P3-COMMS:** comunicaciones.
- **P3-SUPERVISOR:** oficina de supervisión.
- **P3-BRIEFING:** sala de briefing.
- **P3-RECORDS:** almacén de registros.
- **P3-EMERGENCY:** salida de emergencia secundaria; no es la transición narrativa principal al edificio clandestino.
- **P3-LIFT:** vestíbulo del ascensor.

## 2. Aristas principales

1. P0-ELENA-BREACH → P0-AIRLOCK → P0-HALL; P0-CORRIDOR-ACCESS es un acceso separado y no sustituye la brecha de Elena.
2. P0-HALL ↔ P0-SHIFT-ARCHIVE ↔ P0-DISPATCH.
3. P0-HALL ↔ P0-INSTRUMENTS ↔ P0-SAMPLES.
4. P0-HALL ↔ P0-LIFT (ascensor visible, estado sin energía).
5. P0-HALL → conexión vertical/escalera → B2-BATTERY / B2-PUMPS.
6. B2-PUMPS ↔ B2-FILTERS ↔ B2-CABLE-GALLERY ↔ B2-SUBSTATION.
7. B2-SUBSTATION ↔ B2-LIFT-MACHINERY ↔ B2-LIFT.
8. P0-HALL ↔ M-GALLERY ↔ M-SAMPLE-LAB / M-CALIBRATION.
9. M-GALLERY ↔ M-LIFT ↔ P3-LIFT.
10. P3-LIFT ↔ P3-SECURITY ↔ P3-ARCHIVE / P3-CONTROL.
11. P3-CONTROL ↔ P3-COMMS / P3-RECORDS.
12. **P0-SEALED-CONNECTION (ubicación por decidir):** la puerta que comunica ambos edificios es el umbral final de la fase. Su planta, cota y recorrido de acceso aún no están fijados; deben decidirse y representarse de forma coherente en planta, sección y grafo antes del greybox. Al abrirse, conduce al edificio clandestino activo. No asumir que está en P+3 ni sustituirla por una salida de emergencia genérica.

Las aristas 5, 8, 9 y 12 son objetivos de diseño y deben verificarse físicamente: no se consideran construidas por aparecer en el grafo.

## 3. Dependencias de progresión

- **DrawerCode:** deducido con dos indicios de P0-SHIFT-ARCHIVE. La pista explica el método; no es un código aleatorio.
- **SERVICE_KEY:** obtenida al abrir el cajón de P0-DISPATCH; abre P−2-B2-SUBSTATION.
- **INSULATED_BRIDGE:** obtenida en el mismo cajón; conecta el terminal vacío de la subestación.
- **PowerRestored:** requiere llave, puente colocado en el terminal correcto y accionamiento del seccionador.
- **LiftPowered:** depende de PowerRestored. Luces por sectores y sonidos de maquinaria confirman el cambio.
- **ClandestineBuildingAccess:** requiere completar la cadena de investigación y energía, activar los sistemas necesarios y alcanzar la puerta sellada. La geometría y el recorrido de conexión deben aparecer de forma consistente en planta, sección y grafo.

## 4. Espacios opcionales

P0-WAITING, P0-REST, P0-STORAGE, B2-VENT, B2-SPARES, B2-FLOODED, B2-DEAD-WORKSHOP, M-MEETING, M-REST, M-DARK-ANNEX, P3-SEALED-LAB y P3-BRIEFING pueden ser espacios de historia ambiental o exploración. No deben contener objetos de la ruta crítica a menos que se revise explícitamente este grafo. Como mínimo, una ruta opcional debe proporcionar una recompensa comprensible (ventaja, información o atajo) y otra puede terminar sin recompensa funcional.

## 5. Contratos de validación

- Prueba estática: todos los nodos y aristas críticos tienen un identificador estable y una referencia a la puerta/portal de la escena.
- Prueba de reachability: brecha de Elena → cajón → subestación → energía → ascensor/recorrido habilitado → puerta sellada de conexión → edificio clandestino. La ubicación de esa puerta debe resolverse antes de convertir la prueba en un criterio geométrico ejecutable.
- Prueba de bloqueo: el cajón no se abre sin DrawerCode; subestación no abre sin SERVICE_KEY; no se restaura energía sin INSULATED_BRIDGE; ascensor no funciona antes de PowerRestored.
- Prueba de retorno: el jugador puede volver desde P−2 a P0 y desde la galería al núcleo sin softlock.
- QA manual: explorar al menos dos ramales opcionales; verificar que se entienden como espacios secundarios y no como contenido roto.
