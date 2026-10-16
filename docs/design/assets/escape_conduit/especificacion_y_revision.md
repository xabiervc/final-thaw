# FINAL THAW — Atlas vectorial de la huida

Reconstrucción interpretativa. No es un calco geométrico exacto ni una implementación de Godot.

Ruta N1–A2: 199.000 m; A2 inclinada: 57.588 m; total N1–A3: 256.588 m. Acceso S–N1: 13 m adicionales.

## 01_plano_vectorial

FINAL THAW
PLANO DE LA INSTALACIÓN · SECUENCIA DE HUIDA
Reconstrucción vectorial interpretativa de la referencia. Ruta única, bloqueos físicos y causalidad de personajes.
CARRETERA SECUNDARIA · cota de llegada +8 m
BOSQUE
Ocultación final
D01
Galería principal de
drenaje
D02
Achique
D03
Galería de tuberías
D04
Mantenimiento de
drenaje
D05
Acceso técnico
D06
Galería principal de
drenaje
D07
Achique
D08
Galería de tuberías
D09
Mantenimiento de
drenaje
D10
Acceso técnico
B01
Sala de bombas
principales
B02
Depósitos de filtrado
B03
Cámara de válvulas
B04
Tratamiento de agua
B05
Sala técnica
B06
Acceso técnico
bloqueado
B07
Sala de bombas
principales
B08
Depósitos de filtrado
B09
Cámara de válvulas
B10
Tratamiento de agua
B11
Sala técnica
C01
Vestuarios y esclusas
C02
Taller de
mantenimiento
C03
Almacén de repuestos
C04
Sala de control
secundario
C05
Oficinas
C06
Salida de emergencia
bloqueada
C07
Vestuarios y esclusas
C08
Taller de
mantenimiento
C09
Almacén de repuestos
A01
Sala de
transformadores
A02
Galería de cables
A03
Cuadros eléctricos
A04
Climatización HVAC
A05
Baterías y SAI
A06
Grupo electrógeno
A07
Compresores
A08
Sala de
transformadores
A09
Galería de cables
A10
Cuadros eléctricos
S
N1
N2
N3
N4
N5
N6
A2
A3
1
2
3
4
T1
T2
T3
G1
G2
P · pulsador
Solo T1 activa la alarma tras levantarse.
Escalera: 0 → −2 m
A2 · conducción seca +10°
S · desde la instalación inicial
SECTOR D · DRENAJE Y SERVICIO
SECTOR B · BOMBEO E HIDRÁULICA
SECTOR C · PERSONAL Y MANTENIMIENTO
SECTOR A · ELECTRICIDAD Y CLIMATIZACIÓN
N
0
10
20 m
Escala gráfica válida con SVG sin deformar · envolvente 150 × 110 m
1 · ENCUENTRO EN N1 · sin alarma
Tres trabajadores cierran el paso de frente. Elena gira a su izquierda (oeste). El
corredor superior de N1 no es utilizable.
2 · ESTANTERÍA · X azul
[Interactuar] T1 tropieza; T2 y T3 saltan y continúan. Plano breve → primera persona.
T1 se levanta, va al pulsador P y lo acciona FUERA DE PLANO.
3 · ARMARIO · X morada
[Interactuar] Elena vuelca el armario y bloquea a T2 y T3. Cámara breve hacia atrás →
primera persona. La barrera separa la persecución laboral de la respuesta de
seguridad.
4 · EXTINTOR · X verde
G1 y G2 llegan por la alarma, con tiempo de respuesta. [Interactuar] Recoger →
descargar → cegar → golpear mientras están desorientados. Plano breve → primera
persona. Guardias neutralizados.
5 · ESCAPE · D → A2 → A3
Elena sigue por servicio, alcanza A2 y asciende desde −2 hasta +8 m. Sale junto a la
carretera y se oculta en el bosque. Sin teletransportes ni salida alternativa.
SECCIÓN DE LA RUTA · cotas propuestas coherentes
N1 · 0 m
N6 · −2 m
A2 · −2 m
A3 · +8 m
Instalación: 0 m → escalera → galerías a −2 m → conducción seca de salida → exterior a +8 m.
N1 → A2: 199.0 m. A2 inclinada: 57.6 m; proyección horizontal 56.7 m; desnivel +10 m.
Ruta N1 → A3: 256.6 m. Acceso S → N1: 13 m adicionales. Duración objetivo: 2–4 min, no medida.
Sección esquemática, sin escala vertical: no deducir pendientes del dibujo. Solo A2 tiene pendiente definida (+10°).
LEYENDA Y LÍMITES
Naranja: única ruta de escape. Rojo discontinuo: ramal no válido; X roja: impedimento
identificado. Cuadrado amarillo: nodo. Azul/morado/verde: interacción. P: pulsador
humano. Contorno oscuro: pared; relleno sectorial: salas, no pasillo.
RECONSTRUCCIÓN, NO CALCO EXACTO
Se preservan los hitos y la secuencia. Salas renumeradas sin duplicados; cotas N4/N5
ajustadas a −2 m. La ruta y las áreas de sectores de la imagen original no se
presentan como mediciones verificadas.
DISEÑO DE VIDEOJUEGO · Cotas objetivo · No validado en Godot · Sin cambios en el repositorio
1/4 · Rev. V1 · 17-10-2026

## 02_secuencia_y_camara

FINAL THAW
SECUENCIA NARRATIVA, PERSONAJES Y CÁMARA
Tres trabajadores distintos de dos guardias. La alarma depende de una acción humana, no del mueble ni de un sensor.
T0 · ENCUENTRO
N1 · 3 trabajadores · alarma APAGADA
Elena llega desde S. Los trabajadores cierran el frente; la única huida es a la izquierda, por B. No sustituirlos por
guardias.
T1 · ESTANTERÍA
X azul · interacción ambiental 1
Aviso de interacción. Elena derriba la estantería. T1 tropieza; T2 y T3 saltan y siguen persiguiendo. Plano corto que muestra
la consecuencia y retorno a primera persona.
T2 · ALARMA HUMANA
Recuperación de T1 · fuera de plano
T1 se levanta, recorre una ruta física hasta P y pulsa. Solo entonces suena la alarma y arranca la respuesta de seguridad. El
retraso concede ventaja a Elena; no mostrarlo como sensor automático.
T3 · ARMARIO
X morada · interacción ambiental 2
Aviso de interacción. Elena derriba el armario sobre el corredor. T2 y T3 quedan detrás sin ruta lateral que lo evite. Plano
breve hacia atrás; vuelta a primera persona y continuación.
T4 · SEGURIDAD
G1 y G2 · respuesta a ALARM_ACTIVE
Dos guardias se desplazan desde su área. Debe transcurrir un tiempo de respuesta creíble. Coordinación con el avance del
jugador, sin aparición instantánea delante de la cámara.
T5 · EXTINTOR
X verde · interacción ambiental 3
Aviso para recoger. G1/G2 bloquean el paso. Elena recoge, descarga, crea una nube, ciega a ambos y los golpea mientras están
desorientados. Breve plano del resultado y regreso a primera persona.
T6 · SALIDA
Sector D → A2 → A3 → carretera → bosque
Guardias neutralizados, trabajadores retenidos por el armario. Carrera final con menor presión inmediata. Ascenso por
conducción seca; salida física y ocultación en el bosque.
CONTRATO DE PERSONAJES
T1: cae → se levanta → va al pulsador → activa la alarma. T2/T3: saltan la estantería → persiguen → quedan bloqueados por el armario. G1/G2: responden a la alarma →
bloquean → pierden visión → reciben los golpes → quedan incapacitados para perseguir.
CONTRATO DE CÁMARA
Primera persona durante el desplazamiento. Tres insertos breves, motivados por las interacciones; deben mostrar causa y consecuencia sin convertir la huida en cinemáticas
largas. Retorno a la misma posición física, conservando orientación y control, sin teletransportes ni giros involuntarios. La duración de cada inserto se ajusta con
playtest; no se declara aprobada aquí.
DISEÑO DE VIDEOJUEGO · Cotas objetivo · No validado en Godot · Sin cambios en el repositorio
2/4 · Rev. V1 · 17-10-2026

## 03_estados_y_fallos

FINAL THAW
GODOT · ESTADOS, EVENTOS Y RECUPERACIÓN
Diseño propuesto: progreso de misión y respuesta de personajes coordinados, sin depender de un único fotograma.
INITIAL_ENCOUNTER
Elena llega a N1.
Tres trabajadores; alarma apagada; ruta izquierda.
SHELF_INTERACTION
Elena alcanza la estantería e interactúa.
Caída física; T1 tropieza, T2/T3 saltan; inserto de cámara.
WORKER_RECOVERY
Termina la caída de T1.
T1 se levanta y navega al pulsador; no activa por temporizador solo.
ALARM_ACTIVE
T1 alcanza y acciona el pulsador.
Evento único; alarma audible; seguridad recibe aviso.
CABINET_INTERACTION
Elena alcanza el armario e interactúa.
Mueble bloquea físicamente a T2/T3; retorno de cámara.
SECURITY_ARRIVAL
Respuesta a alarma y recorrido de G1/G2 completado.
Ambos ocupan el encuentro; sin spawns instantáneos visibles.
EXTINGUISHER_INTERACTION
Elena recoge y usa el extintor ante G1/G2.
Descarga → nube → pérdida temporal de visión → golpes.
SECURITY_DISABLED
Termina la acción y se confirman sus consecuencias.
G1/G2 incapacitados para perseguir; paso despejado.
ESCAPE_RUN
Paso libre hacia D y A2.
Control de movimiento, continuidad física y menor presión.
ESCAPE_COMPLETE
Elena alcanza A3 y el exterior.
Concluir salida y ocultación; fin de la secuencia.
DOS PROCESOS EN PARALELO, NO UNA CADENA RÍGIDA
Elena puede seguir corriendo mientras T1 se recupera. WORKER_RECOVERY y la respuesta de guardias deben convivir con el progreso de ruta; no congelar a Elena para
esperar una transición global. La llegada de seguridad depende de ALARM_ACTIVE y de un trayecto/tiempo de respuesta, no solo de cruzar un trigger.
FALLOS QUE HAY QUE CUBRIR
• Sin interacción: aviso legible, posibilidad de reaproximarse y fallo/reintento justo si la alcanzan; no ejecutar el objeto a distancia.
• Abandono del área o animación interrumpida: evento idempotente, colisiones y control restaurados, objeto en un estado consistente.
• NPC atascado: detectar el bloqueo y recuperar su navegación de forma segura; nunca fingir que T1 pulsó si no llegó al pulsador.
• Guardias retrasados / jugador rápido o lento: validar tiempos y rutas; no teletransportarlos ni cambiar la causalidad para cuadrar el guion.
• Cada transición confirma estado y resultado; no depende de que cámara y NPC coincidan en una posición exacta durante un único fotograma.
DISEÑO DE VIDEOJUEGO · Cotas objetivo · No validado en Godot · Sin cambios en el repositorio
3/4 · Rev. V1 · 17-10-2026

## 04_aceptacion_y_cotas

FINAL THAW
CRITERIOS DE ACEPTACIÓN Y CONTROL DE COTAS
Lista de revisión completa. Todo se marca pendiente: esta entrega contiene diseño vectorial, no ejecución del juego.
01. El encuentro de N1 ocurre con la alarma apagada; los tres personajes iniciales son trabajadores, no guardias.
02. Elena gira a la izquierda; el corredor superior de N1 no es una ruta de huida válida.
03. La estantería presenta aviso de interacción, cae físicamente y hace tropezar a T1; T2 y T3 saltan y continúan.
04. La caída NO activa la alarma automáticamente, ni mediante sensor, ni como simple efecto del trigger de la estantería.
05. T1 se levanta y llega al pulsador; la acción humana, fuera de plano, es la causa verificable de la alarma.
06. La alarma se oye con retraso perceptible y antes de la intervención de G1/G2; respuesta con tiempo creíble.
07. El armario presenta aviso, cae y bloquea a T2/T3 sin huecos laterales; Elena gana una ventaja considerable.
08. G1 y G2 son dos personajes distintos de T1/T2/T3 y llegan como consecuencia de ALARM_ACTIVE.
09. El extintor se recoge y utiliza mediante interacción: nube y pérdida temporal de visión antes de los golpes.
10. Los dos guardias quedan neutralizados para la persecución y Elena puede continuar por D hacia A2.
11. La cámara principal es primera persona; cada inserto muestra la consecuencia y vuelve sin perder posición ni orientación.
12. La secuencia sigue siendo una huida jugable: movimiento entre interacciones, insertos breves y control restaurado.
13. La ruta naranja es la única conexión de escape: sin pasos por muros, bloques restringidos, fondos de saco o perímetro.
14. El recorrido se completa físicamente hasta A2/A3, carretera secundaria y ocultación en el bosque.
15. No interacción, salida de trigger, animación interrumpida y NPC atascado tienen recuperación o fallo justo, sin softlocks.
16. Longitud y duración se miden en Godot; los 220–260 m y 2–4 min son objetivos, no pruebas de jugabilidad.
DISCREPANCIAS DE LA REFERENCIA Y RESOLUCIÓN EXPLÍCITA
Cotas y pendiente
Se conserva S/N1 = 0 m; N6 = −2 m; A3 = +8 m. A2 salva +10 m. A +10° requiere 56,7 m de proyección y 57,6 m inclinados. No confundir grados con porcentaje:
equivalencia calculada 17,6 %.
Sección original
El rótulo original de ~80 m para A2 no coincide con +10 m a +10°. Esta versión dimensiona A2 en 57,6 m inclinados y NO la presenta como 80 m. El perfil es
esquemático, no a escala vertical.
Nodos y numeración
N1 encuentro; N2 cruce hidráulico; N3 cruce eléctrico no utilizable; N4 cruce superior; N5 bifurcación; N6 acceso a conducción. N4/N5 pasan a −2 m para evitar
un desnivel omitido. A2/A3 son hitos de salida; salas con IDs de sector únicos.
Áreas
Envolvente objetivo 150 × 110 m = 16.500 m², sin sumar la conducción exterior. Las áreas originales B 4.800, D 4.500, C 3.800 y A 3.400 m² se conservan como
referencias históricas, no como medidas de esta nueva división.
Anchuras y alturas
Objetivos de referencia: principales 3,5–4,5 m; secundarios 2,2–3,0 m; pasajes técnicos 1,8–2,5 m; altura libre 2,8–4,5 m. El eje de huida se dibuja a 3,5 m.
Puertas, dobles puertas, escaleras, rampas y pozos deben comprobarse en construcción.
Alcance y validación
La violencia con extintor se conserva tal como la solicita el propietario; esta lámina no aprueba ni modifica contratos del repo. No se ha ejecutado Godot,
validado la IA, escuchado audio ni probado la cámara. Sin commits ni push.
DISEÑO DE VIDEOJUEGO · Cotas objetivo · No validado en Godot · Sin cambios en el repositorio
4/4 · Rev. V1 · 17-10-2026
