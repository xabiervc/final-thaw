# FINAL THAW — Arquitectura espacial de Fase 1 (v2.0)

**Estado:** dirección de diseño confirmada por el usuario; revisión de topología y planos en curso. Esta versión redefine el recorrido final respecto a v1.1. Los SVG describen el objetivo arquitectónico; geometría, colisiones, cámara, navegación y transición a Fase 2 siguen pendientes de validación en Godot. No declarar la fase aceptada por documentación o revisión estática.

## 1. Intención arquitectónica

Fase 1 ocurre dentro de **una única instalación clandestina de investigación hidrológica/industrial**, evacuada con prisa y parcialmente abandonada. No es una ruina genérica ni un decorado de salas conectadas por puertas arbitrarias. Debe poder leerse como un edificio que tuvo una función real: acceso y descontaminación, nave de ensayos, taller, distribución eléctrica, achique, bombeo, observación, control, archivo restringido y logística de servicio.

La arquitectura es el sistema que sostiene exploración, investigación, puzle y persecución. Las tuberías, bandejas, cuadros, colectores, señalización, desgaste, reparaciones improvisadas y huellas de evacuación deben permitir inferir cómo funciona el edificio y qué ocurrió. La columna de calibración Aster es el hito visual que conecta nave, mezzanine y pasarela superior.

**Principios obligatorios**
- Un perímetro de edificio legible, con espesor de muros, umbrales, patios/huecos y conexiones verticales coherentes.
- La mayoría de las áreas representadas son explorables y tienen un propósito. Las áreas restringidas deben explicarse por cerraduras, derrumbes, riesgo industrial o seguridad, nunca por límites invisibles.
- El puzle se descubre a través del conjunto de la instalación. Las pistas pueden encontrarse en distintos sectores; ninguna lectura opcional debe convertirse en una llave arbitraria.
- La ruta principal y la ruta de huida son diferentes. La huida puede atravesar áreas de trabajo potencialmente ocupadas: el diseño debe soportar primero evasión silenciosa y después una carrera bajo persecución. No se sale por el túnel de entrada ni se teletransporta al aparcamiento.
- La arquitectura, los SVG, el grafo, la progresión, los contratos funcionales, la escena Godot y las pruebas deben compartir nombres, cotas, huellas y conexiones.
- La escala y la circulación se validan con el volumen real de Elena, su cámara y los colliders; el dibujo bonito no sustituye a una prueba de recorrido.

## 2. Organización por cotas

La instalación mantiene cuatro cotas interiores conectadas y una salida de servicio exterior. Las cotas existentes se conservan como base para reducir riesgo de implementación.

| Cota | Programa arquitectónico |
|---|---|
| **P−1 · Y=−2 m** | D1 galería de achique; D2 distribución hidráulica/eléctrica; puente A→T manipulado; interruptor de mantenimiento; sumidero y colectores; conexión a la ruta de salida de servicio. El lado exacto de salida queda sujeto a la ruta de huida aprobada. |
| **P0 · Y=0 m** | Túnel de entrada oeste; A esclusa de acceso; B nave de ensayos Aster; C taller; cuadros auxiliares; galería de servicio; retorno por perímetro sur/este; acceso inferior del elevador; boca superior de S1. |
| **M · Y=+1,5 m** | Sala de bombas, colectores y manómetros; galería de observación; rellano del elevador; llegada de S2; corredor técnico de conexión. |
| **P2 · Y=+3 m** | E control y diagnóstico; F archivo restringido; pasarela superior; G esclusa de doble puerta. Abrir la compuerta exterior activa la amenaza; Elena retrocede al interior y escapa por conexiones técnicas existentes. G no es la salida final. |
| **Exterior · cota variable** | Boca de servicio/descarga conectada físicamente al aparcamiento. El lado del perímetro y la cota exterior se deciden desde la ruta completa de huida; no se fuerza una coordenada para coincidir con el plano local de parking. |

La huella puede crecer si el plano acotado demuestra que el recorrido de huida no cabe con anchos seguros. No comprimir pasillos, escaleras ni espacios de combate/persecución para preservar una dimensión arbitraria del prototipo.

## 3. Programa de estancias y función jugable

| Zona | Función del edificio | Función jugable / acceso |
|---|---|---|
| Túnel oeste | Acceso técnico secundario | Entrada y orientación inicial; no será la salida final. |
| A · Esclusa | Control de entrada y descontaminación | Introduce el protocolo y da una primera vista a la nave. |
| B · Nave Aster | Ensayos de calibración | Hito visual, lectura del espacio y obstáculos industriales de recorrido; no activar la máquina de ensayo. |
| C · Taller | Reparación y mantenimiento | Área explorable con utilería funcional y evidencias ambientales; sin llave artificial obligatoria. |
| Galería de servicio P0 | Distribución técnica | Une taller, retorno y elevador; debe tener ancho transitable y orientación clara. |
| D1 · Achique | Extracción de agua | Bombas, marcas de nivel, colector y evidencia de la instalación bajo cota. |
| D2 · Distribución | Conducción de circuito | Esquema previsto, puente físico A→T manipulado e interruptor de mantenimiento. |
| M · Bombas/observación | Bombeo y supervisión de Aster | Confirma efectos del mantenimiento, enlaza elevador y S2 y permite leer verticalmente la nave. |
| E · Control | Supervisión del circuito | Probar hipótesis, ver diagnóstico y recuperarse de un error. |
| F · Archivo | Registro restringido | Consultar con ARCHIVO estable; la consulta no equivale a extracción. |
| G · Esclusa de doble puerta | Interbloqueo de seguridad exterior | Tras resolver lo necesario, abrir la compuerta exterior envía la auditoría e inicia Containment; Elena retrocede por la puerta interior hacia F/E. Primero hay evasión silenciosa; la carrera empieza tras una reacquisición real en un umbral expuesto definido en el grafo. No es la salida final ni un cambio de escena inmediato. |
| Ruta de huida | Circulación de emergencia y mantenimiento, con posibles áreas operativas ocupadas | Evitar personal y percepción de Containment en un primer tramo de bajo perfil; después correr por un tramo expuesto con obstáculos físicos legibles. No requiere combate. |
| Galería de evacuación | Descarga de servicio | Ruta final alternativa; conduce a una boca exterior distinta del túnel de entrada. |
| Aparcamiento | Logística exterior | Primer espacio de Fase 2; handoff continuo a la persecución existente. |

“Explorable casi en su totalidad” no significa que todas las puertas deban abrirse en cualquier momento. Significa que los espacios principales tienen circulación justificable y que los bloqueos son diegéticos, comprensibles y verificables. No crear salas de relleno para aumentar el tamaño aparente.

## 4. Circulación vertical y rutas

Se preservan las conexiones verticales ya definidas:
1. **S1 · P0↔P−1:** escalera fija, siempre utilizable; también forma parte de la ruta de huida.
2. **Elevador · P0↔M:** elevador de mantenimiento, habilitado por mantenimiento; no llega a P2.
3. **S2 · M↔P2:** escalera fija, independiente de alimentación.
4. **Escalera directa P0↔P2:** colapsada y bloqueada; se ve como parte del historial del edificio, no como ruta alternativa.
5. **G → F/E → pasarela/S2/M → áreas de trabajo y servicio → P0/S1/P−1 → salida alternativa → aparcamiento:** ruta objetivo de Fase 1. El primer tramo prioriza sigilo entre áreas potencialmente ocupadas; R1, en la transición de la galería de servicio al retorno este P0 tras el elevador, eleva la presión a carrera antes de S1/P−1. La unidad sigue a Elena por el mismo elevador y la reacquiere por LOS real. La secuencia exacta debe aparecer en planos y grafo. No se exige que la salida coincida con el transform provisional del parking.
6. **Entrada → túnel oeste → A:** solo entrada inicial; no reutilizar como salida final.

La galería de evacuación de P−1 es una nueva conexión arquitectónica respecto a v1.1. Debe dibujarse en el plano de P−1 y en sección; no puede implementarse como teletransporte. Si la cota exterior exige rampa, escalera o tramo de descarga, debe representarse y tener pendiente/altura transitables. No añadir conexiones secretas arbitrarias: la salida debe ser una infraestructura de servicio coherente con el edificio.

## 5. Puzle distribuido por el edificio

El puzle principal conserva el contrato eléctrico existente. El edificio aporta evidencia complementaria:
- **A/B:** primera lectura de Aster, canalizaciones y disposición de la nave.
- **C/P0:** paneles auxiliares, reparaciones y etiquetas de mantenimiento que orientan sin revelar la solución.
- **D1/D2/P−1:** comparación entre el esquema de distribución y el puente A→T manipulado; activar mantenimiento.
- **M:** comprobar el efecto físico del mantenimiento en bombas, iluminación y elevador; entender que ese circuito no equivale a la protección de recuperación.
- **E:** diagnóstico y maniobra del circuito, con errores reversibles.
- **F:** consulta condicionada a ARCHIVO estable; aporta contexto, no una llave que haga funcionar el circuito.
- **G:** envía la auditoría e inicia Containment; no fuerza una carrera instantánea. La sección silenciosa precede al segmento de persecución a la carrera.

Las pistas deben reforzarse entre sí mediante geometría, texto, estado de maquinaria y continuidad de tuberías/cables. El escáner revela continuidad A→T; no marca la respuesta correcta ni señala los controles. La máquina de ensayo nunca arranca. No añadir llaves, coleccionables o puzles secundarios obligatorios sin decisión explícita.

## 6. Desenlace de Fase 1 y continuidad con Fase 2

La secuencia final prevista es:
1. Elena completa la configuración funcional necesaria y llega a G.
2. La puerta se abre físicamente y el jugador ve/oye una respuesta del edificio; no se produce una transición instantánea al aparcamiento.
3. La huida interior empieza con evasión silenciosa en áreas potencialmente ocupadas. Después, en un umbral espacial definido y anticipado, la unidad reacquiere a Elena y la secuencia pasa a una persecución a la carrera. El jugador debe atravesar obstáculos industriales legibles (p. ej. una compuerta que baja, una pasarela parcialmente bloqueada o equipo desplazado), con alternativas de movimiento coherentes con el espacio y sin exigir una única maniobra no comunicada.
4. La ruta obliga a abandonar P2 y descender por la circulación técnica hacia M/P0/P−1. No se inventa un ascensor adicional ni una escalera nueva para resolver el guion.
5. La galería de evacuación conduce a una salida exterior distinta de la entrada oeste.
6. La salida exterior seleccionada conecta de forma continua con el aparcamiento. El checkpoint de entrada de Fase 2 se integra a partir de la boca real; no se fuerza el recorrido interior para conservar coordenadas del prototipo.
7. Fase 2 continúa la huida en el aparcamiento. La escena standalone del corredor conserva su checkpoint propio.

El contrato narrativo provisional define que mantenimiento encola `SERVICE_OVERRIDE` y que cruzar el umbral exterior de G envía la auditoría e inicia Containment. La huida se diseña en dos ritmos: bajo perfil entre personal y cobertura real, seguido de una carrera cuando la unidad reacquiere a Elena en un punto espacial definido. Esto fija intención jugable, no acredita implementación. Siguen abiertas la identidad del destinatario, el grado de supervisión humana, la motivación de la supresión y la identidad final de la unidad de recuperación. La necesidad arquitectónica de la huida y su ruta alternativa sí quedan fijadas por esta dirección.

## 7. Autoridad, coordinación y criterios de aceptación

- Este documento fija la intención y programa espacial de referencia.
- `FASE1_SPATIAL_GRAPH.md` fija nodos, aristas y accesibilidad.
- Los SVG existentes fijan las plantas y la sección; deben mostrar la nueva ruta de huida, no limitarse a etiquetarla en texto.
- `FASE1_GREYBOX_SPEC.md` fija huellas, alturas libres, anchos y elementos de colisión.
- `FASE1_FUNCTIONAL_SPEC.md` fija el puzle, los estados y los beats jugables.
- `fase1_fase2_mapa_progresion.md` fija el recorrido y los cambios de estado.
- `FASE1_LOGIC_CONTRACT.md` mantiene las reglas del circuito salvo aprobación explícita de cambios.
- `FASE1_CANONICAL_BUILD.md` documenta implementación y pruebas; no redefine diseño para acomodar limitaciones del código.

La arquitectura solo se acepta cuando:
1. Cada planta y sección coincide con las huellas de la escena.
2. El perímetro y las estancias se leen como un edificio único.
3. Las zonas principales son accesibles y las restricciones están justificadas.
4. La ruta de ida, el retorno tras D1/D2 y la ruta de huida se distinguen y se recorren sin saltos.
5. Los anchos, escaleras, puertas, barandillas, obstáculos y altura libre funcionan con la cápsula, cámara y controles reales.
6. La puerta G inicia Containment; la huida interior incluye una sección silenciosa y otra a la carrera; la salida exterior es diferente de la entrada y conecta físicamente con el aparcamiento.
7. Se ejecutan las pruebas automáticas y el playtest manual; se registra versión de Godot, renderer, commit, comandos, resultados, incidencias y evidencia visual.

No se afirma aceptación geométrica o jugable hasta ejecutar Godot y completar las pruebas.