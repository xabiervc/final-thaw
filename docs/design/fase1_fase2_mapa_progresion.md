# FINAL THAW — Fases 1 y 2: mapa de progresión verificable (v1.0)

**Estado:** recorrido y estructura de la experiencia revisados según la dirección arquitectónica de edificio completo, puzle distribuido y huida por una salida alternativa. La escena actual aún no demuestra este recorrido: la nueva galería de evacuación, la persecución interior y el handoff al aparcamiento requieren implementación y pruebas. Los beats narrativos concretos de Helix/Containment siguen pendientes de cierre; no presentarlos como canon sin aprobación.

**Autoridad:** `FASE1_ARCHITECTURAL_LAYOUT.md v2.0`, `FASE1_SPATIAL_GRAPH.md v1.0`, `FASE1_GREYBOX_SPEC.md`, `FASE1_FUNCTIONAL_SPEC.md` y `FASE1_LOGIC_CONTRACT.md`. El contrato lógico del circuito no cambia con este mapa.

## Experiencia objetivo

La misión ocurre en una instalación clandestina de investigación hidrológica/industrial parcialmente abandonada. La persona jugadora investiga el edificio como un sistema: sigue tuberías y canalizaciones, contrasta la documentación con el estado físico, activa mantenimiento, entiende la anomalía eléctrica y decide cómo alimentar el archivo de forma segura. Tras abrir la puerta G, la experiencia cambia de investigación a huida física. El jugador debe atravesar el edificio bajo persecución y salir por la galería de servicio de P−1, distinta del túnel por el que entró, para llegar al aparcamiento y continuar en Fase 2.

## Progresión espacial y de información

| Beat | Espacio | Qué aprende/hace el jugador | Contrato / condición |
|---|---|---|---|
| 1. Entrada | Túnel oeste → A | Entra por una instalación técnica real; identifica protocolo de acceso y ve la nave Aster. | Spawn dentro del túnel; salida oeste no será la ruta final. |
| 2. Lectura del edificio | A/B/C/P0 | Reconoce el rig central, taller, cuadros y canalizaciones; puede explorar áreas auxiliares sin encontrar llaves arbitrarias. | Los accesos y el perímetro deben tener colisiones coherentes; áreas principales legibles. |
| 3. Investigar el subsuelo | B → S1 ↓ D1/D2 | Compara el esquema de distribución con el puente físico A→T manipulado. | S1 transitable siempre; suelo continuo en P−1; D1/D2 diferenciados por equipo y señalización. |
| 4. Restablecer mantenimiento | D2 | Activa mantenimiento y ve cómo cambian iluminación, bombas y disponibilidad del elevador. | Mantenimiento no alimenta la protección de recuperación. |
| 5. Volver a P0 | S1 ↑ → retorno sur/este → galería de servicio | Aprende la topología; rodea el hueco en lugar de cruzarlo. | La ruta existe físicamente y es verificable con cámara/colliders. |
| 6. Confirmar el sistema | Elevador ↑ M → bombas/observación | Relaciona el estado del edificio con las instalaciones de P−1 y localiza la ruta a control. | Elevador P0↔M; S2 independiente de alimentación. |
| 7. Resolver el circuito | S2 ↑ E | Contrasta hipótesis, usa diagnóstico y opera aislador/selector/rearme. Puede fallar y recuperarse. | Contrato lógico existente; el escáner revela continuidad A→T, nunca los controles. |
| 8. Consultar la evidencia | E → F | Consulta el archivo si ARCHIVO está estable. El texto contextualiza la anomalía; no actúa como llave. | Consulta no equivale a extracción ni modifica el guardado persistente en este hito. |
| 9. Abrir la puerta | F → G | Abre la puerta de salida/interbloqueo. La respuesta del edificio hace perceptible que la situación ha cambiado. | G no teletransporta al exterior. Este acto inicia la huida. |
| 10. Huida interior | G → pasarela/corredor técnico → S2 ↓ M | La amenaza persigue a Elena. El jugador interpreta el espacio y atraviesa obstáculos industriales legibles. | Obstáculos con colisión, anticipación visual y al menos una solución justa; no depender de un salto ciego. |
| 11. Descenso de servicio | M → elevador ↓ P0 → S1 ↓ P−1 | Regresa por la infraestructura técnica y llega al nivel de achique. La ruta es distinta de la entrada y se siente como parte del mismo edificio. | No crear ascensor ni escalera nueva. Estado del elevador durante la huida debe estar diseñado y probado. |
| 12. Salida alternativa | D2 → galería de evacuación → boca este | Cruza el corredor de descarga/servicio y sale al exterior. | Galería y salida física nuevas en planos/código; nunca un teletransporte. |
| 13. Handoff | Exterior de servicio → aparcamiento | Entra en la zona de aparcamiento; la persecución exterior continúa como Fase 2. | La escena existente de parking-chase debe arrancar en el checkpoint de entrada, sin reiniciar el corredor standalone. |

## Puzle y evidencia distribuida

- **P0, nave/taller:** la disposición de Aster, los cuadros y las canalizaciones establece el contexto y da orientación. La exploración es útil pero no obliga a leer cada objeto.
- **P−1, D1/D2:** la anomalía principal es física: el esquema previsto y el puente A→T no coinciden. Mantenimiento permite observar el sistema, pero no resuelve la protección.
- **M:** las bombas y la iluminación hacen visible el efecto del mantenimiento; la elevación cambia la perspectiva y conecta subsistemas.
- **P2, E:** el diagnóstico presenta estado actual y último disparo como datos separados. ENSAYO conectado al seleccionar ARCHIVO dispara DEMANDA_SIMULTANEA; aislar y rearmar tras eliminar el fallo permite recuperarse.
- **F:** consulta solo con ARCHIVO estable. El archivo aporta contexto y no desbloquea por sí solo los controles.
- **Escáner:** mantener `scan` durante 0,9 s; revela continuidad durante 3 s y tiene 4 s de recarga desde activación. No revela la acción correcta.

La progresión debe funcionar por inferencia ambiental, no por una lista de recados. Las pistas refuerzan el razonamiento, pero los controles siguen operativos sin leer cada una.

## Diseño de la persecución

La persecución comienza **dentro** del edificio al abrir G. No se debe implementar todavía como una transición directa a la escena del aparcamiento.

Requisitos del segmento interior:
- La amenaza tiene un punto de entrada y una línea de persecución explicables por el edificio.
- O1: estantería caída en F/P2, centro aproximado (6,8; 3,0; −5,6), volumen 1,6 × 1,1 × 2,0 m. La solución es rodearla por el paso visible, con un ancho libre objetivo de 1,2 m.
- O2: bastidor de tuberías desplazado en M, centro aproximado (18,0; 1,5; −3,0), volumen 2,0 × 0,8 × 1,2 m. La solución es rodearlo sin invadir el acceso a S2 o elevador.
- O3: bandeja desprendida en la galería P0, centro aproximado (25,0; 0,0; −0,5), volumen 1,2 × 0,8 × 0,6 m. La solución es usar el paso lateral claramente visible, manteniendo acceso a S1.
- Estas ubicaciones son una primera propuesta de layout; los SVG y el builder deben coincidir antes de construir colliders definitivos. Si el playtest revela una maniobra injusta, corregir plano, geometría y test juntos.
- Cada obstáculo tiene colisión, ruta de aproximación y recuperación ante fallo; la dificultad no se basa en un collider invisible.
- La cámara de tercera persona mantiene lectura de bordes, escalones, huecos y perseguidor.
- La velocidad y el ritmo permiten percibir la arquitectura; el recorrido no puede depender de conocer de memoria la ruta.
- El retorno por S2/M/elevador/S1 debe ser continuo. El estado del elevador al abrir G debe estar definido y probado; no improvisar una escalera nueva.
- La galería de evacuación tiene un cambio claro de luz/espacio al salir al exterior, con continuidad visual al aparcamiento.

La lista definitiva de obstáculos y sus estados se cierra en la especificación de greybox y se cubre con pruebas de comportamiento. No añadir combate obligatorio.

## Fase 2: aparcamiento

El aparcamiento incluye contexto legible —acceso de servicio, carriles, plazas, pilares y vehículos inmóviles— y una ruta que recibe al jugador desde la boca este. Se reutiliza `scenes/prototypes/phase2_parking_chase.tscn` si sus contratos de checkpoint, percepción y navegación lo permiten. La versión standalone del corredor conserva su punto de inicio original.

El handoff se acepta solo cuando:
1. G inicia la huida interior.
2. Elena atraviesa la ruta interior con el perseguidor activo.
3. Llega a la boca de servicio de P−1.
4. El exterior se conecta visualmente y físicamente al aparcamiento.
5. La escena de parking empieza en el checkpoint de entrada, no al inicio standalone.
6. El perseguidor no detecta a Elena antes de que la secuencia lo permita.
7. No se pierde estado de misión ni se duplica el jugador al cambiar de escena.

## Estado de decisiones

- **Dirección fijada:** laboratorio completo y explorable en gran parte; puzle integrado en el edificio; G abre la huida interior; persecución antes de salir; salida alternativa a parking.
- **Contrato existente que se conserva:** circuito, estados iniciales, recuperación reversible, escáner, mantenimiento y elevador P0↔M.
- **Diseño por cerrar en plano/greybox:** huella final de la galería de evacuación, medidas del recorrido de persecución, posiciones de obstáculos, puertas y estados de seguridad.
- **Narrativa pendiente:** evento exacto recibido por Helix, auditoría de F, percepción de Elena, causa y timing de Containment, identidad/entrada de la amenaza y destino posterior.
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