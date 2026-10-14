# FINAL THAW — Fase 1: grafo espacial (v0.4)

**Estado:** decisiones espaciales cerradas para construir el slice; validación de escena pendiente. No se afirma que haya recorridos, colisiones, cámara o jugabilidad validados en Godot.

**Autoridad funcional:** FASE1_FUNCTIONAL_SPEC.md v1.0.  
**Geometría base:** FASE1_GREYBOX_SPEC.md v1.1.  
**Lógica eléctrica:** FASE1_LOGIC_CONTRACT.md.

Convención: [R] geometría base anterior; [D] decisión ahora cerrada; ninguna marca [P] queda abierta dentro del slice. Coordenadas en metros; Y es altura y Z positivo hacia el sur.

## 1. Decisiones definitivas

1. **Recorrido único A:** foso y mantenimiento antes de subir a E. El estado inicial de mantenimiento es OFF y la plataforma elevadora no se mueve sin él. No existe una ruta de rampa en el slice final; la variante B queda retirada y no es un criterio de aceptación.
2. **Una única plataforma:** es la plataforma del elevador en la huella original X=24.5..27.5, Z=-4.5..-1.5, de Y=0 a Y=3. Se elimina la segunda reserva de plataforma X=30..34 y se elimina la rampa provisional. No hay dos transportes compitiendo por el anexo.
3. **Fallo de energía:** parada segura hacia el rellano más cercano con reserva de seguridad; empate exacto se resuelve hacia el rellano superior, de acuerdo con `service_lift.gd`. Al llegar, plataforma deshabilitada hasta reactivar mantenimiento. Nunca caída ni atrapamiento entre niveles.
4. **Rearme:** interacción en soporte fuera del borde norte de la pasarela, centrada aproximadamente en (15.5,3.5,-8.15). Selector y aislador conservan exactamente (12,3,-7) y (19,3,-7).
5. **Panel E:** soporte de estado cerca de (15.5,4.55,-8.15), cara al sur; el punto (15,3,-7) sigue siendo punto de observación, no una ubicación de indicador.
6. **Indicador F:** interior de la entrada este, (8.55,3.8,-7), cara hacia +X y visible desde la pasarela antes de entrar. La consola de archivo sigue en (5,3,-7).
7. **Salida G→H:** G usa el vestíbulo oeste de la cabina. La compuerta exterior se abre hacia H desde la pared oeste X=0; la escalera del vestíbulo hacia Y=0 es un retorno secundario y no la transición a H. No se simula presurización. El cruce exterior transmite la auditoría de servicio y activa Containment.
8. **Iluminación:** el mantenimiento apaga/enciende luces de servicio, pero la escalera del foso y su ruta conservan iluminación ambiental mínima y legible.

## 2. Nodos y geometría de referencia

| Nodo | Posición / envolvente | Función |
|---|---|---|
| Entrada | (3,0,7) | Orientación inicial; cabina visible |
| Escalera directa rota | X 2..4, Z -3..3 | Barrera física; inspección desde (4,0,3), no atravesable |
| Ruta sur / pasillo oeste | X 7..19.5, Z 5..7; X 17.5..19.5, Z 5..10, Y=0 | Ruta al foso |
| Explanada | X 20..28, Z 8..12, Y=0 | Boca de escalera |
| Escalera fija del foso | (25,0,11) a (25,-2,8) | Acceso y salida sin energía |
| Foso | X 20..28, Z 1..8, Y=-2 | Esquema (27,-2,6); puente (22,-2,4); mantenimiento (26,-2,2) |
| Ruta este / rellano inferior | X 28..30; X 24..28, Z -1..1, Y=0 | Camino a la plataforma |
| Plataforma elevadora | X 24.5..27.5, Z -4.5..-1.5; Y=0..3 | Transporte vertical único, controlado por mantenimiento |
| Rellano superior | X 24..28, Z -7..-4.5, Y=3 | Conecta plataforma con pasarela |
| Pasarela pública | X 9..26, Z -8..-6, Y=3 | Selector (12,3,-7), aislador (19,3,-7), observación (15,3,-7) |
| Cabina / archivo | X 2..9, Z -9..-5, Y=3 | Consola de archivo (5,3,-7), entrada este (9,3,-7), diagnóstico |
| Atajo oeste / vestíbulo G | puerta F→G en X=2; vestíbulo X 0..2, Z -9..-6, Y=3 | Desbloqueo desde la cabina, después bidireccional |
| Compuerta exterior G→H | pared oeste X=0, Z -8.25..-6.75, Y=3..5.2 | Umbral de salida a la transición H |

Se elimina del diseño el anexo de transporte X=30..34 y no se construye la rampa descrita en revisiones previas.

## 3. Recorrido implementable

```text
Entrada
 -> ruta sur -> pasillo oeste -> explanada
 -> escalera fija -> foso: esquema, puente y mantenimiento ON
 -> vuelta por la misma escalera -> ruta este -> plataforma elevadora
 -> rellano superior -> pasarela E
 -> configurar circuito -> entrada este -> consulta de archivo F
 -> desbloquear puerta oeste desde la cabina -> vestíbulo G
 -> compuerta exterior -> H
```

La visita al foso es una dependencia física: mantenimiento comienza apagado y la plataforma necesita su alimentación. La visita al foso no obliga a leer el esquema o el puente; las pistas ayudan a inferir el circuito, pero no son llaves para las interacciones de E.

La estimación horizontal entre el pie de la escalera del foso (25,-2,8) y el interruptor (26,-2,2) es de unos 6 m. El recorrido pasa por el esquema y es mayor. La escalera fija sigue siendo la salida del foso aunque se apaguen luces o falle la plataforma.

## 4. Detalle espacial de controles

- **Selector y aislador:** conservar sus coordenadas contractuales e interacción. Sus cuerpos visuales deben montarse de modo que el recorrido conserve el ancho claro especificado.
- **Panel E:** centro aproximado (15.5,4.55,-8.15), mirando hacia +Z. Presenta destino, conexión del ensayo, estado de protección y si existe último disparo. No recomienda acciones.
- **Rearme:** interacción independiente en (15.5,3.5,-8.15), en el soporte norte fuera del área libre Z=-8..-6; alcance desde la pasarela de aproximadamente 0.55 m. Separar visualmente la interacción del panel y de selector/aislador.
- **Indicador F:** (8.55,3.8,-7), montado en el interior del acceso este, cara +X. Textos únicos: SUMINISTRO ESTABLE / NO DISPONIBLE. No indica qué control accionar.
- **Diagnóstico:** terminal completo siempre accesible en la cabina F, aunque la protección esté disparada.

## 5. Salida y relación con H

La puerta entre cabina y vestíbulo oeste se desbloquea desde dentro una vez y luego es bidireccional. La compuerta oeste del vestíbulo es la salida a H; no se obliga a volver a la entrada ni bajar la escalera para cambiar de fase. La escalera de vuelta a Y=0 permanece como salida secundaria del vestíbulo.

El interruptor de mantenimiento genera SERVICE_OVERRIDE local; la consulta de archivo añade RESTRICTED_RECORD_READ cuando ocurre. Al cruzar G→H, el relé de salida sincroniza los eventos y dispara Containment. H es una transición de escena independiente apoyada en el prototipo de persecución. La unidad comienza patrullando y usa visión, línea de visión y ruido; no conoce la posición de Elena por guion.

## 6. Criterios de aceptación

| Prueba | Resultado exigido |
|---|---|
| Dependencia A | Plataforma inmóvil con mantenimiento OFF; tras activarlo desde el foso, permite alcanzar E |
| Ruta del foso | Escalera usable sin alimentación y ruta legible con luces de servicio apagadas |
| Plataforma | Llamadas en ambos extremos; movimiento en 2.5 s; pérdida de potencia siempre termina en un rellano sin caída ni atrapamiento |
| E | Interacciones separadas, circulación legible y controles contractuales intactos |
| Panel/rearme | Panel legible desde (15,3,-7); rearme separado y fuera del ancho libre |
| F | Indicador visible desde la pasarela; consulta inaccesible cuando el suministro no es estable |
| G | Se puede llegar a H desde el vestíbulo sin volver a la entrada; la auditoría se sincroniza al cruzar |
| Colisiones y cámara | No hay rutas atravesables por la escalera rota, caída en bordes, pasos bloqueados ni cortes de cámara que impidan leer los controles |

Registrar versión de Godot, commit, resolución, renderer, dispositivo de entrada, secuencia, salida de pruebas y observaciones manuales. Diseño aprobado no equivale a escena validada.

## 7. Historial v0.4

- Se unifica el transporte en la plataforma de la huella original del elevador.
- Se retiran la reserva X=30..34, la rampa provisional y la variante B.
- Se decide posición del panel E, rearme, indicador F y compuerta exterior.
- Se cierra la causa funcional de Containment mediante sincronización de auditoría en la salida.
