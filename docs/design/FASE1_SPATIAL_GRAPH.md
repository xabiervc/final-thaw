# FINAL THAW — Fase 1: grafo espacial (v3.1 · conexión clandestina en P−2)

**Estado:** topología objetivo acordada; aún requiere greybox y reconciliación con Godot. El nivel construido anteriormente está documentado en [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md). Este grafo describe el objetivo nuevo, no el runtime actual.

## 1. Modelo de navegación

La instalación se organiza en una espina de circulación por nivel y varios ramales con distinto peso. La nave central es el hito de orientación. P−2 es accesible por una conexión vertical desde P0; la puerta clandestina no requiere subir a P+3 ni utilizar el ascensor. El jugador puede descubrir espacios, puertas y pistas en distinto orden, pero las dependencias de los objetos se mantienen.

### P0 — Entrada e investigación

- **P0-CORRIDOR-ACCESS:** acceso arquitectónico antiguo al pasillo principal; separado del inicio de Elena.
- **P0-ELENA-BREACH:** brecha/alcantarilla de servicio por la que entra Elena; colapsa físicamente tras su entrada y bloquea el retorno.
- **P0-AIRLOCK:** esclusa y vestíbulo de personal.
- **P0-LOCKERS:** vestuarios; espacio ambiental.
- **P0-SHIFT-ARCHIVE:** pizarra de turnos y tira de presión; dos indicios para deducir el código del cajón.
- **P0-DISPATCH:** despacho con cajón; entrega SERVICE_KEY e INSULATED_BRIDGE al introducir el código deducido.
- **P0-WAITING / P0-REST / P0-STORAGE:** salas opcionales ambientales.
- **P0-HALL:** nave central de gran altura con columna Aster, maquinaria de bombeo y vistas a la mezzanine; hito visual.
- **P0-INSTRUMENTS:** taller de instrumentos; contexto opcional.
- **P0-SAMPLES:** lavado y muestras.
- **P0-LIFT:** vestíbulo del ascensor; transporte bloqueado hasta PowerRestored.
- **P0-STAIR-B2:** conexión vertical accesible entre P0 y P−2; no depende de la alimentación del ascensor.

### P−2 — Energía, mantenimiento y transferencia

- **B2-PUMPS:** cámara de achique y bombas principales.
- **B2-FILTERS:** tratamiento de agua.
- **B2-BATTERY:** baterías auxiliares.
- **B2-SUBSTATION:** sala eléctrica con puerta cerrada por SERVICE_KEY; terminal para INSULATED_BRIDGE y seccionador.
- **B2-CABLE-GALLERY:** galería de cables entre sistemas de energía y maquinaria.
- **B2-VENT:** ventilación; opcional.
- **B2-SPARES:** almacén de repuestos; contiene un armario seco elevado por encima de la marca de humedad y la TRANSFER_KEY.
- **B2-SUMP:** foso de mantenimiento.
- **B2-FLOODED:** cuarto inundado; ambiental/opcional.
- **B2-DEAD-WORKSHOP:** taller muerto; franja de suelo limpia, marcas de arrastre, corriente de aire en la junta y nota de mantenimiento. La inspección revela el panel oculto.
- **B2-TRANSFER-DOOR:** puerta de transferencia oculta en el muro oriental de B2-DEAD-WORKSHOP. Está cerrada al descubrirla y requiere TRANSFER_KEY + PowerRestored.
- **B2-CLANDESTINE-VESTIBULE:** vestíbulo técnico del segundo edificio activo, inmediatamente al otro lado de B2-TRANSFER-DOOR. Es el umbral narrativo hacia Fase 2.
- **B2-LIFT-MACHINERY / B2-LIFT:** maquinaria y núcleo del ascensor.

### M +1,50 — Mezzanine parcial

- **M-GALLERY:** pasarela parcial junto a la nave; permite ver el vacío central, no lo cubre.
- **M-SAMPLE-LAB:** laboratorio de muestras.
- **M-INSTRUMENTS:** instrumentos de reserva.
- **M-CALIBRATION:** banco de calibración.
- **M-MEETING / M-ARCHIVE / M-UPPER-WORKSHOP / M-REST / M-DUCTS:** salas de ala lateral.
- **M-DARK-ANNEX:** anexo oscurecido, opcional.
- **M-LIFT:** conexión al núcleo del ascensor.

### P+3 — Ala superior de control

- **P3-SECURITY:** seguridad y monitorización.
- **P3-ARCHIVE:** archivo restringido.
- **P3-CONTROL:** control de instalaciones.
- **P3-SEALED-LAB:** laboratorio sellado; contexto, no llave obligatoria.
- **P3-COMMS / P3-SUPERVISOR / P3-BRIEFING / P3-RECORDS:** espacios de control y documentación.
- **P3-EMERGENCY:** salida de emergencia secundaria; nunca es la transición principal al edificio clandestino.
- **P3-LIFT:** vestíbulo del ascensor.

## 2. Aristas espaciales

1. P0-ELENA-BREACH → P0-AIRLOCK → P0-HALL. P0-CORRIDOR-ACCESS es un acceso independiente.
2. P0-HALL ↔ P0-SHIFT-ARCHIVE ↔ P0-DISPATCH.
3. P0-HALL ↔ P0-INSTRUMENTS ↔ P0-SAMPLES.
4. P0-HALL ↔ P0-LIFT.
5. P0-HALL ↔ P0-STAIR-B2 ↔ B2-CABLE-GALLERY / B2-PUMPS. Esta ruta debe seguir siendo transitable aunque el ascensor esté sin energía.
6. B2-PUMPS ↔ B2-FILTERS ↔ B2-CABLE-GALLERY ↔ B2-SUBSTATION.
7. B2-SUBSTATION ↔ B2-LIFT-MACHINERY ↔ B2-LIFT.
8. B2-CABLE-GALLERY ↔ B2-SPARES.
9. B2-CABLE-GALLERY ↔ B2-DEAD-WORKSHOP.
10. B2-DEAD-WORKSHOP → B2-TRANSFER-DOOR → B2-CLANDESTINE-VESTIBULE. La puerta se descubre desde el taller y comunica con el segundo edificio; no se dibuja como salida de emergencia.
11. P0-HALL ↔ M-GALLERY ↔ M-SAMPLE-LAB / M-CALIBRATION.
12. M-GALLERY ↔ M-LIFT ↔ P3-LIFT.
13. P3-LIFT ↔ P3-SECURITY ↔ P3-ARCHIVE / P3-CONTROL.
14. P3-CONTROL ↔ P3-COMMS / P3-RECORDS.

Las aristas describen topología objetivo. Antes de considerarlas construidas, deben verificarse los huecos de puerta, anchuras, cotas, alturas, colisiones y navegación en el greybox.

## 3. Pistas y dependencias de progresión

### Código del cajón

- **DrawerCode:** la pizarra indica B → D → A → C. La tira de presión muestra A=3, B=0, C=7, D=4. La deducción produce 0437; ninguna tarjeta entrega el código completo.

### Cadena A — restauración eléctrica

- **SERVICE_KEY:** se obtiene del cajón de P0-DISPATCH y abre B2-SUBSTATION.
- **INSULATED_BRIDGE:** se obtiene del mismo cajón y ocupa el terminal vacío del panel.
- **PowerRestored:** requiere SERVICE_KEY para acceder, INSULATED_BRIDGE colocado correctamente y accionar el seccionador.
- **LiftPowered:** depende de PowerRestored. Relés, zumbido, luces parciales, bombas auxiliares e indicador del ascensor confirman el cambio.

### Cadena B — puerta de transferencia

- **HiddenDoorDiscovered:** requiere inspeccionar en B2-DEAD-WORKSHOP la franja limpia, las marcas de arrastre y la corriente de aire; se revela el panel, pero la puerta no se abre.
- **TransferKeyClue:** la nota del taller indica que la llave se guardó en el armario seco del almacén después de una fuga.
- **TRANSFER_KEY:** se obtiene del armario seco elevado de B2-SPARES; su símbolo coincide con el de la puerta.
- **ClandestineBuildingAccess:** requiere HiddenDoorDiscovered + TRANSFER_KEY + PowerRestored.

Las cadenas son independientes hasta la puerta. SERVICE_KEY e INSULATED_BRIDGE no abren la puerta de transferencia; TRANSFER_KEY no abre la subestación ni restaura la energía. La llave y la nota pueden encontrarse en cualquier orden de exploración, pero el umbral no puede cruzarse hasta cumplir ambas condiciones.

## 4. Espacios opcionales

P0-WAITING, P0-REST, P0-STORAGE, B2-VENT, B2-FLOODED, M-MEETING, M-REST, M-DARK-ANNEX, P3-SEALED-LAB y P3-BRIEFING son ramales ambientales u opcionales. B2-DEAD-WORKSHOP y B2-SPARES son necesarios para la cadena de transferencia, pero deben leerse como espacios de exploración natural, no como salas de búsqueda de píxeles. Como mínimo, una rama opcional independiente ofrece una ventaja/contexto comprensible y otra puede terminar sin recompensa funcional.

## 5. Contratos de validación

- **Prueba estática:** cada nodo y arista crítica tiene un identificador estable y una referencia a la puerta/portal correspondiente.
- **Reachability:** brecha → P0 → escalera a P−2 → taller muerto → puerta descubierta → armario seco/TRANSFER_KEY; en paralelo, cajón → SERVICE_KEY + INSULATED_BRIDGE → subestación → PowerRestored. Ambas cadenas convergen en B2-TRANSFER-DOOR → B2-CLANDESTINE-VESTIBULE.
- **Bloqueos:** cajón sin DrawerCode; subestación sin SERVICE_KEY; circuito incompleto sin INSULATED_BRIDGE; ascensor apagado antes de PowerRestored; puerta clandestina cerrada sin TRANSFER_KEY o sin PowerRestored.
- **No softlock:** la escalera permite volver entre P0 y P−2 sin ascensor; el jugador puede explorar puerta, nota y almacén en distinto orden.
- **QA manual:** probar al menos dos ramales opcionales y comprobar que se entienden como contenido secundario, no como rutas rotas.
- **Verificación visual:** validar desde la cámara real que los indicios de la puerta son perceptibles y que el umbral revela una zona activa sin mostrarla por completo antes de abrir.
