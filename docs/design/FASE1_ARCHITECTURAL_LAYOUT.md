# FINAL THAW — Arquitectura espacial de Fase 1 (v3.0 · rediseño ampliado)

**Estado:** dirección de diseño acordada; aún no implementada ni validada como geometría jugable. La geometría construida anterior se documenta en [FASE1_PREMIUM_AUDIT.md](FASE1_PREMIUM_AUDIT.md); no confundir este objetivo con el as-built. La conexión clandestina se fija en P−2, en el taller muerto, y la sección vertical se coordina para preservar la nave central de gran altura.

## 1. Objetivo y escala

El edificio que Elena explora debe parecer abandonado: su deterioro y la falta de actividad visible lo convierten en una cobertura idónea para ocultar una instalación clandestina. Está conectado mediante una puerta de seguridad sellada a un segundo edificio donde los antagonistas siguen trabajando. Esa puerta es el umbral narrativo de la fase y solo se abre tras reunir los elementos y restablecer los sistemas necesarios. La instalación debe sentirse como un complejo industrial real, no como el mismo nivel con habitaciones añadidas. La huella conceptual pasa de **30 × 23,5 m (705 m² brutos)** a **48 × 34 m (1.632 m² brutos)**: **2,32× la huella anterior**. Es una meta geométrica de diseño, no una afirmación de superficie útil ya construida. La superficie útil real se medirá descontando muros, huecos y áreas inaccesibles al terminar el greybox.

Se conservan cuatro cotas de suelo: P−2 = −4,00 m (servicios y energía), P0 = ±0,00 m (entrada e investigación), M = +1,50 m (mezzanine parcial de observación) y P+3 = +3,00 m (ala superior de control y archivo). Estas cotas son elevaciones del suelo, no alturas libres. El núcleo del ascensor se alinea entre niveles. La nave central mantiene 6–8 m de altura libre y queda abierta a través de la mezzanine y de la planta superior; M solo ocupa una banda lateral de menor altura y P+3 se concentra en alas laterales, sin forzar un forjado que cruce la nave. Como objetivo preliminar, P−2 tendrá 3,2–3,5 m de altura libre, salas ordinarias de P0 3,5–4,5 m y zonas superiores 3,0–3,5 m, sujetos a reconciliación con espesores estructurales y colisiones.

## 2. Principios espaciales

- **Exploración con memoria:** se puede ver el ascensor apagado en P0 antes de saber cómo activarlo; la subestación y la galería de cables se descubren antes o después del cajón, pero no pueden resolverse sin los objetos necesarios.
- **Salas no obligatorias:** sala de espera, vestuarios, cuarto de limpieza, almacén secundario, sala de pausa, taller muerto y anexo oscurecido aportan escala, huellas de uso y relato ambiental. No deben contener todos una pista crítica.
- **Conexiones legibles:** una espina de circulación organiza cada planta; puertas laterales, escaleras y el ascensor conectan zonas. Los planos deben mostrar las conexiones y no sugerir accesos que no puedan construirse.
- **Causa y efecto visibles:** conectar el puente eléctrico debe producir una secuencia audible y visible: relés, zumbido de transformador, luces por sectores y ascensor que recupera servicio. Algunas luminarias permanecen averiadas para conservar tensión.
- **No convertir la exploración en una búsqueda de píxeles:** los objetos clave se distinguen por silueta, contexto, iluminación y composición; las pistas ambientales opcionales no se confunden con los requisitos de progresión.
- **No mantener mecánicas por inercia:** la lógica eléctrica anterior solo se conserva si supera la nueva revisión de diseño y comprensión; el rediseño no está obligado a reproducir el circuito antiguo.

## 3. Programa por nivel

### P0 — Entrada, investigación y nave
1. **Dos accesos distintos:** (a) el **acceso antiguo al pasillo principal**, una entrada arquitectónica del edificio que no es el punto de inicio de Elena; (b) la **brecha de Elena**, un conducto o acceso de servicio por el que entra al inicio y que se derrumba después. El derrumbe bloquea físicamente su retorno. En los planos deben rotularse «ACCESO AL PASILLO» y «BRECHA DE ELENA — COLAPSADA TRAS ENTRAR» respectivamente.
2. **Vestíbulo de personal y vestuarios:** espacios ambientales; lockers, prendas y objetos de turno comunican presencia humana.
3. **Archivo de turno:** la pizarra indica el orden B → D → A → C; la tira registra A=3, B=0, C=7, D=4. Leer las cifras en el orden indicado produce 0437. Los dos indicios se encuentran separados y ninguno muestra la respuesta completa.
4. **Despacho con cajón cerrado:** el código abre el cajón. Dentro están la **llave de servicio** de la subestación y un **puente aislado** para el embarrado eléctrico.
5. **Sala de espera, descanso, almacén y limpieza:** ramales secundarios; pueden aportar relato, una ventaja opcional o nada mecánicamente necesario.
6. **Nave central y columna Aster:** hito visual y punto de orientación. El ascensor se ve, pero está sin alimentación. La puerta de conexión con el segundo edificio debe distinguirse de las puertas ordinarias: es una barrera de seguridad cerrada hasta completar la cadena de investigación, llave, puente y energía.
7. **Taller de instrumentos y lavado/muestras:** conectan la historia del trabajo con la instalación técnica y contienen indicios opcionales.

### P−2 — Energía, achique, mantenimiento y transferencia clandestina
1. Cámara de achique, filtros de agua y bombas principales.
2. Baterías auxiliares y galería de cables.
3. Subestación cerrada con la **llave de servicio**; panel con dos terminales claramente identificables y un puente ausente.
4. Maquinaria del ascensor y foso de mantenimiento con visibilidad controlada.
5. Almacén de repuestos, cuarto inundado y ventilación como espacios secundarios. El almacén contiene un **armario seco** elevado por encima de la marca de humedad; guarda la llave de transferencia, con el mismo símbolo que la puerta oculta.
6. **Taller muerto:** ramal ambiental donde una franja de suelo anormalmente limpia, marcas recientes de arrastre y una corriente de aire en la junta del muro llevan a inspeccionar un panel oculto. El panel revela una puerta de transferencia, pero no la abre. Una nota de mantenimiento explica que, tras una fuga, la llave de transferencia se guardó en el armario seco del almacén de repuestos.
7. La puerta de transferencia ocupa el muro oriental del taller muerto y conduce directamente a un corto vestíbulo técnico del segundo edificio activo. El umbral permanece bloqueado hasta usar la **llave de transferencia** y restaurar la alimentación necesaria. No se coloca en P+3 ni se sustituye por una salida de emergencia.
8. La llave de transferencia es un objeto distinto de la llave de servicio y del puente aislado. La llave de servicio + puente + seccionador restauran energía parcial; la llave de transferencia abre el umbral narrativo. La exploración y el hallazgo de ambas cadenas pueden ocurrir en distinto orden.

### M +1,50 — Mezzanine y observación
Galería sobre la nave, laboratorio de muestras, instrumentos de reserva, banco de calibración, sala de reuniones, archivo secundario, taller superior, sala de pausa, ductos de servicio y anexo oscurecido. La galería sirve para leer el espacio desde arriba y orientar al jugador. Las barandillas, caídas y rutas de retorno deben validarse con el controlador real.

### P+3 — Control y archivo restringido
Vestíbulo restringido, seguridad/monitorización, archivo restringido, control de instalaciones, laboratorio sellado, comunicaciones, supervisión, briefing, almacén de registros, pasillo de servicio, salida de emergencia y vestíbulo del ascensor. Los archivos aportan contexto y anticipación; no se añadirá otra cadena de llaves obligatoria por defecto.

## 4. Puzle de investigación, energía y puerta de transferencia

**Cadena A — energía:**
1. Leer la pizarra de turnos y observar la tira de presión en el archivo de turno.
2. Deducir el código del cajón: la pizarra ordena las pruebas B → D → A → C; la tira de presión muestra las últimas cifras estables A=3, B=0, C=7, D=4. En ese orden, el código es 0437. No aparece escrito explícitamente en ninguna tarjeta.
3. Abrir el cajón del despacho y obtener llave de servicio + puente aislado.
4. Explorar P−2 y localizar la subestación; la puerta requiere la llave.
5. Observar el hueco en el embarrado y emparejar el puente por forma y señalización.
6. Insertar el puente y activar el seccionador.
7. Ver y oír el cambio de estado: relés, luces que se encienden por sectores, bombas auxiliares y ascensor activo.
8. Usar el ascensor para acceder a las alas superiores y obtener contexto; esta subida no sustituye la transición al edificio clandestino.

**Cadena B — transferencia clandestina:**
1. Explorar P−2 y observar en el taller muerto la franja limpia, las marcas de arrastre y la corriente de aire en la junta.
2. Inspeccionar la anomalía para descubrir el panel y la puerta oculta. La puerta permanece cerrada y no ofrece una interacción de apertura sin la llave.
3. Leer la nota de mantenimiento del taller: después de una fuga, la llave de transferencia se guardó en el armario seco del almacén de repuestos.
4. Localizar el armario elevado por encima de la marca de humedad y reconocer el símbolo que coincide con el de la puerta.
5. Obtener la llave de transferencia. El símbolo y el contexto deben ser legibles sin búsqueda de píxeles.
6. Volver a la puerta oculta y usar la llave de transferencia. La puerta solo completa la apertura cuando la alimentación requerida está restablecida.
7. Cruzar a un vestíbulo técnico del segundo edificio y revelar actividad clandestina real: iluminación de trabajo, maquinaria activa, señales recientes de uso y sonido humano/operativo. Este cruce cierra Fase 1 y abre la transición narrativa a Fase 2.

Las dos cadenas son independientes hasta el umbral final: la llave de servicio y el puente no abren la puerta de transferencia; la llave de transferencia no abre la subestación ni restaura la energía. Se puede descubrir la puerta antes de restaurar la energía o conseguir la llave; no se puede entrar en el segundo edificio hasta cumplir ambas condiciones. Al menos un descubrimiento opcional debe aportar contexto o ventaja sin bloquear la ruta crítica.

## 5. Reglas para los planos y la futura escena

- Las cinco láminas SVG enlazadas desde este documento son esquemas conceptuales a escala de huella; las divisiones interiores son zonificación, no planos constructivos.
- No implementar una puerta, escalera, acceso vertical o atajo porque aparezca dibujado: primero reconciliar posición, dimensiones, altura libre, colisión, navegación y salida de emergencia.
- Los recorridos críticos deben admitir ida y vuelta cuando la progresión lo requiera; no crear habitaciones accesibles solo visualmente que no tengan acceso jugable.
- Las salas secundarias pueden ser espacios muertos intencionales, pero deben tener una razón ambiental y no parecer un fallo de navegación.
- La geometría definitiva se comprobará en Godot con greybox, medidas del controlador y playtest humano.

## 6. Planos

- [P0 — Entrada, investigación y nave](assets/phase1_architecture/plan_p0.svg)
- [P−2 — Energía, achique y mantenimiento](assets/phase1_architecture/plan_p_minus2.svg)
- [M +1,50 — Mezzanine y observación](assets/phase1_architecture/plan_m_plus1_5.svg)
- [P+3 — Control, archivo y ascensor](assets/phase1_architecture/plan_p_plus3.svg)
- [Sección vertical conceptual](assets/phase1_architecture/section_vertical.svg)

## 7. Criterios de aceptación del diseño

- La huella bruta conceptual es 1.632 m² y la comparación con la referencia de 705 m² queda explícita (2,32×).
- La sección representa la nave central de 6–8 m de altura libre, la mezzanine parcial y las alas superiores sin forjados que crucen el vacío de la nave; las cotas de suelo no se confunden con las alturas libres.
- Todos los niveles incluyen una ruta principal legible y salas opcionales que no son todas contenedores de objetos.
- Cajón, llave de servicio, puente, subestación, alimentación parcial, ascensor, nota de mantenimiento, armario seco, llave de transferencia y puerta oculta tienen ubicaciones y dependencias explícitas.
- Planta P−2, sección, grafo y progresión sitúan la conexión clandestina en el muro oriental del taller muerto y describen el mismo recorrido. La puerta no se ubica en P+3 ni en una salida de emergencia.
- El greybox se juega antes de producir arte final; se miden tiempos, confusiones, rutas alternativas, retornos y comprensión del puzle.
- La propuesta no se considera implementada ni validada hasta superar pruebas automáticas de estructura y una sesión de juego real.
