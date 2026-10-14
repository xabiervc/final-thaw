# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v1.0)

**Estado:** recorrido y estructura de la experiencia revisados según la dirección arquitectónica de edificio completo, puzle distribuido y huida por una salida alternativa. La escena actual aún no demuestra este recorrido: la evasión silenciosa, la transición a carrera, la salida alternativa seleccionada y el handoff al aparcamiento requieren implementación y pruebas. La galería/boca este dibujada actualmente es una candidata, no una restricción de guion. El inicio narrativo y sus beats/diálogos provisionales se especifican en `docs/narrative_complete.md`; no son canon completo aprobado. La respuesta automática de la instalación es la dirección narrativa propuesta; siguen abiertas la supervisión exacta, el destinatario concreto y la identidad final de la unidad.

**Autoridad:** `FASE1_ARCHITECTURAL_LAYOUT.md v2.0`, `FASE1_SPATIAL_GRAPH.md v1.0`, `FASE1_GREYBOX_SPEC.md`, `FASE1_FUNCTIONAL_SPEC.md` y `FASE1_LOGIC_CONTRACT.md`. El contrato lógico del circuito no cambia con este mapa.

## Experiencia objetivo

La misión ocurre en una instalación clandestina de investigación hidrológica/industrial parcialmente abandonada. La persona jugadora investiga el edificio como un sistema: sigue tuberías y canalizaciones, contrasta la documentación con el estado físico, activa mantenimiento, entiende la anomalía eléctrica y decide cómo alimentar el archivo de forma segura. Tras abrir G, la experiencia cambia de investigación a evasión y huida física en dos ritmos. Primero, Elena se mueve en silencio por salas de trabajo donde aún puede haber personal: debe evitar líneas de visión, ruido y atención, sin combate obligatorio. Después, al quedar expuesta en un tramo de servicio legible o ser reacquirida por Containment, la secuencia pasa a una persecución a la carrera. La salida final debe ser distinta del túnel de entrada y conectarse físicamente con el aparcamiento; su ubicación exacta se elige por la calidad del recorrido, no por una coordenada heredada.

## Progresión espacial y de información

| Beat | Espacio | Qué aprende/hace el jugador | Contrato / condición |
|---|---|---|---|
| 1. Entrada | Túnel oeste → A | Entra por una instalación técnica real; identifica protocolo de acceso y ve la nave Aster. | Spawn dentro del túnel; salida oeste no será la ruta final. |
| 2. Lectura del edificio | A/B/C/P0 | Reconoce el rig central, taller, cuadros y canalizaciones; puede explorar áreas auxiliares sin encontrar llaves arbitrarias. | Los accesos y el perímetro deben tener colisiones coherentes; áreas principales legibles. |
| 3. Investigar el subsuelo | B → S1 ↓ D1/D2 | Compara el esquema de distribución con el puente físico A→T manipulado. | S1 transitable siempre; suelo continuo en P−1; D1/D2 diferenciados por equipo y señalización. |
| 4. Restablecer mantenimiento | D2 | Activa mantenimiento, encola `SERVICE_OVERRIDE` como estado de misión separado y ve cómo cambian iluminación, bombas y disponibilidad del elevador. | Mantenimiento no alimenta la protección de recuperación; `SERVICE_OVERRIDE` no altera el modelo eléctrico y solo se envía al abrir G. |
| 5. Volver a P0 | S1 ↑ → retorno sur/este → galería de servicio | Aprende la topología; rodea el hueco en lugar de cruzarlo. | La ruta existe físicamente y es verificable con cámara/colliders. |
| 6. Confirmar el sistema | Elevador ↑ M → bombas/observación | Relaciona el estado del edificio con las instalaciones de P−1 y localiza la ruta a control. | Elevador P0↔M; S2 independiente de alimentación. |
| 7. Resolver el circuito | S2 ↑ E | Contrasta hipótesis, usa diagnóstico y opera aislador/selector/rearme. Puede fallar y recuperarse. | Contrato lógico existente; el escáner revela continuidad A→T, nunca los controles. |
| 8. Consultar la evidencia | E → F | Consulta el archivo si ARCHIVO está estable. El texto contextualiza la anomalía; no actúa como llave. | Consulta no equivale a extracción ni modifica el guardado persistente en este hito. |
| 9. Abrir la puerta | F → G | Abre la compuerta exterior de la esclusa G. Si `SERVICE_OVERRIDE` está encolado, el umbral transmite la auditoría, la amenaza entra y Elena retrocede al interior por la puerta hacia F/E; la respuesta del edificio hace perceptible el cambio. | G no teletransporta al exterior. Este acto inicia la huida. |
| 10. Evasión silenciosa | G → F/E → pasarela → S2/M y espacios de trabajo conectados | Elena se retira evitando al personal presente y los barridos de Containment. Se apoya en cobertura arquitectónica, tiempos de paso y control del ruido. | Ruta legible, zonas de observación, refugios reales y estados de NPC; no combate/takedown obligatorio ni NPC usados como paredes. |
| 11. Ruptura de sigilo / persecución | Umbral expuesto definido en el grafo → retorno por M/P0 | Un evento espacial comprensible —reacquisición de la unidad, cruce de una zona visible o cierre de una puerta ya anticipada— cambia la evasión a carrera. El jugador lee el cambio y debe reaccionar sin corte de cámara. | El trigger se fija en plano/grafo y se prueba; no usar detección omnisciente ni forzar una muerte. El sigilo anterior debe cambiar realmente la presión o el estado de búsqueda. |
| 12. Descenso y salida alternativa | M → elevador ↓ P0 → S1 ↓ P−1 → ruta de servicio/evacuación elegida | Elena completa la huida por una circulación de servicio distinta de la entrada; la salida puede situarse en otra zona del perímetro si el plano y la sección la justifican. | Conexiones verticales existentes; cualquier nuevo corredor debe aparecer en planta/sección y en el grafo. Salida física, no transición invisible. |
| 13. Handoff | Exterior de servicio → aparcamiento | Entra en la zona de aparcamiento; la persecución exterior continúa como Fase 2. | La escena existente de parking-chase debe arrancar en el checkpoint de entrada, sin reiniciar el corredor standalone. |

## Puzle y evidencia distribuida

- **P0, nave/taller:** la disposición de Aster, los cuadros y las canalizaciones establece el contexto y da orientación. La exploración es útil pero no obliga a leer cada objeto.
- **P−1, D1/D2:** la anomalía principal es física: el esquema previsto y el puente A→T no coinciden. Mantenimiento permite observar el sistema, pero no resuelve la protección.
- **M:** las bombas y la iluminación hacen visible el efecto del mantenimiento; la elevación cambia la perspectiva y conecta subsistemas.
- **P2, E:** el diagnóstico presenta estado actual y último disparo como datos separados. ENSAYO conectado al seleccionar ARCHIVO dispara DEMANDA_SIMULTANEA; aislar y rearmar tras eliminar el fallo permite recuperarse.
- **F:** consulta solo con ARCHIVO estable. El archivo aporta contexto y no desbloquea por sí solo los controles.
- **Escáner:** mantener `scan` durante 0,9 s; revela continuidad durante 3 s y tiene 4 s de recarga desde activación. No revela la acción correcta.

La progresión debe funcionar por inferencia ambiental, no por una lista de recados. Las pistas refuerzan el razonamiento, pero los controles siguen operativos sin leer cada una.

## Evasión y persecución interior

Abrir G con `SERVICE_OVERRIDE` encolado inicia Containment, pero no obliga a correr inmediatamente. Elena retrocede por F/E y atraviesa una sección silenciosa por espacios que pueden seguir ocupados. La carrera empieza en R1, la transición de la galería de servicio al retorno este de P0 (X≈29, Z≈1): Elena sale del elevador existente, la unidad la sigue físicamente y la reacquiere por LOS real. R1 es el punto de diseño por defecto; una detección anterior solo adelanta la carrera si existe LOS real. No implementar una transición directa al aparcamiento al abrir G.

Requisitos del segmento interior:
- La fase silenciosa tiene cobertura física, NPC con percepción/rutinas y rutas de patrulla legibles; evitar al personal es viable sin eliminarlo.
- La carrera empieza en un umbral espacial concreto, anunciado por arquitectura y señales del edificio; la unidad reacquiere por percepción real. R1 está fijado como objetivo de diseño en P0; deben coordinarse su huella/collider y la línea de visión en planta, sección y grafo.
- La amenaza tiene un punto de entrada y una línea de persecución explicables por el edificio.
- O1: estantería caída en F/P2, centro aproximado (8,0; 3,0; −7,0), volumen 1,0 × 1,1 × 0,8 m. La solución es rodearla por el paso visible, con un ancho libre objetivo de 1,2 m.
- O2: bastidor de tuberías desplazado en M, centro aproximado (18,0; 1,5; −3,0), volumen 2,0 × 0,8 × 1,2 m. La solución es rodearlo sin invadir el acceso a S2 o elevador.
- O3: bandeja desprendida en la galería P0, centro aproximado (22,5; 0,0; −1,5), volumen 1,2 × 0,8 × 0,6 m. La solución es usar el paso lateral claramente visible, manteniendo acceso a S1.
- Estas ubicaciones son una primera propuesta de layout; los SVG y el builder deben coincidir antes de construir colliders definitivos. Si el playtest revela una maniobra injusta, corregir plano, geometría y test juntos.
- Cada obstáculo tiene colisión, ruta de aproximación y recuperación ante fallo; la dificultad no se basa en un collider invisible.
- La cámara de tercera persona mantiene lectura de bordes, escalones, huecos y perseguidor.
- La velocidad y el ritmo permiten percibir la arquitectura; el recorrido no puede depender de conocer de memoria la ruta.
- El retorno por S2/M/elevador/S1 debe ser continuo. El estado del elevador al abrir G debe estar definido y probado; no improvisar una escalera nueva.
- La galería de evacuación tiene un cambio claro de luz/espacio al salir al exterior, con continuidad visual al aparcamiento.

La lista definitiva de obstáculos y sus estados se cierra en la especificación de greybox y se cubre con pruebas de comportamiento. No añadir combate obligatorio.

## Fase 2: aparcamiento

El aparcamiento incluye contexto legible —acceso de servicio, carriles, plazas, pilares y vehículos inmóviles— y una ruta que recibe al jugador desde la salida exterior finalmente seleccionada. La planta usa coordenadas locales; no obliga a reutilizar la boca este ni el transform provisional. Se reutiliza `scenes/prototypes/phase2_parking_chase.tscn` si sus contratos de checkpoint, percepción y navegación lo permiten. La versión standalone del corredor conserva su punto de inicio original.

El paquete conceptual del parking incluye planta, sección, overlay de amenaza y overlay de iluminación/hitos en `docs/design/assets/phase2_parking/`; la especificación de arquitectura/rutas/encuentros está en `docs/LEVEL_STRUCTURE.md`. El aparcamiento mantiene un sistema de coordenadas local. Se descarta como restricción el transform provisional X+28,7/Z−15,8: solo intentaba hacer coincidir una entrada conceptual con una boca aún no validada. Cuando se cierre la ruta de salas y la salida exterior, se elegirá la transformación/rotación o se ajustará el plano para garantizar continuidad física sin forzar el recorrido interior.

El handoff se acepta solo cuando:
1. G inicia Containment, pero no salta directamente a la escena de aparcamiento.
2. La sección de evasión silenciosa tiene NPC/estados, cobertura y percepción verificables.
3. Un trigger espacial legible permite la transición a la carrera sin teletransporte ni corte de cámara.
4. Elena atraviesa la ruta interior con el perseguidor activo.
5. La salida alternativa seleccionada se alcanza sin teletransporte ni conexiones no dibujadas.
6. El exterior se conecta visualmente y físicamente al aparcamiento.
7. La escena de parking empieza en el checkpoint de entrada, no al inicio standalone.
8. La percepción de personal y unidad es coherente con LOS, ruido, cobertura y estado de búsqueda.
9. No se pierde estado de misión ni se duplica el jugador al cambiar de escena.

## Estado de decisiones

- **Dirección fijada:** laboratorio completo y explorable en gran parte; puzle integrado en el edificio; G inicia Containment; la huida combina evasión silenciosa por áreas potencialmente ocupadas y una fase de carrera; salida distinta de la entrada y continuidad física con parking.
- **Contrato existente que se conserva:** circuito, estados iniciales, recuperación reversible, escáner, mantenimiento y elevador P0↔M.
- **Diseño por cerrar en plano/greybox:** huella final de la galería de evacuación, medidas del recorrido de persecución, posiciones de obstáculos, puertas y estados de seguridad.
- **Contrato narrativo provisional del opening:** mantenimiento encola `SERVICE_OVERRIDE`; cruzar el umbral exterior de G envía la auditoría y activa Containment. El registro revela que el resultado fue retenido y la recomendación de despliegue suprimida. La implementación, el destinatario/supervisión y la motivación de la supresión siguen sin estar verificados o cerrados.
- **Narrativa aún abierta:** motivo de la supresión, cadena de mando concreta, identidad final/arte de la unidad, cronología completa, papel de Iris/Selene en esta secuencia y destino posterior. Ver `docs/narrative_complete.md`.
- **Validación pendiente:** ejecución de todas las escenas, colisiones, cámara, navegación, secuencia de huida, salida física y transición al aparcamiento.

## Orden de trabajo

1. Coordinar plantas y sección con el nuevo grafo; cerrar huellas, anchos, puertas y recorrido de huida.
2. Actualizar la especificación de greybox con galería de evacuación, salida exterior y obstáculos medibles.
3. Reconciliar la escena canónica con los planos antes de añadir arte o narrativa.
4. Definir tests de navegación y estados para puerta G, persecución interior, descenso y salida alternativa.
5. Integrar con la escena existente del aparcamiento y conservar el inicio standalone.
6. Ejecutar pruebas unitarias, integración y regresión de Fase 0; realizar playtest manual.
7. Registrar commit, versión de Godot, renderer, comandos, exit codes, errores, warnings y evidencia visual.

La Fase 1 no se declara terminada hasta que la secuencia completa sea recorrible en runtime y la ruta de huida se comprenda sin conocimiento previo del diseño.