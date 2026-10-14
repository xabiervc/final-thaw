# Fase 1 — Especificación espacial independiente

Estado: propuesta de plano para revisión. No construido ni validado. No autoriza misión completa. Lógica en FASE1_LOGIC_CONTRACT.md; sustituye la distribución plana del documento anterior solo para el nuevo prototipo.

## Coordenadas y dimensiones propuestas

Metros; Y vertical, X oeste-este, Z sur positivo. Bahía interior X 0..30, Z -10..10; suelo principal Y=0. Superficies indicadas por su cara superior. Elena usa cámara tercera persona orbital, no la cámara elevada antigua. Arte final fuera de alcance.

## Planta y sección

```text
NORTE Z=-10
 [cabina/archivo]---[controles]----[desembarco superior]
      | atajo                         | plataforma
 [acceso directo roto]     [máquina]  |
                                      |
 [entrada]---[rodeo sur]---[escalera al foso]
SUR Z=+10

Y=+3: cabina -- controles -- pasarela -- desembarco
Y= 0: entrada -- rodeo -- embarque inferior
Y=-2: foso -- esquema -- puente -- mantenimiento
```

El diagrama orienta; las coordenadas siguientes fijan la distribución.

## Volúmenes y recorrido

- Entrada: (3,0,7), orientada hacia cabina (6,3,-7). No colocar masa opaca en el corredor visual entre ambas por encima de la máquina.
- Máquina central: huella X 11..18, Z -2..3, altura máxima 2 m en el primer greybox para dejar visible la cabina. Sin colisión sobre las rutas.
- Cabina: plataforma X 2..9, Z -9..-5, Y=3. Archivo en (5,3,-7), acceso este en (9,3,-7). Acristalamiento provisional no opaco hacia entrada; sin detalle artístico requerido.
- Acceso directo roto: escalera fija X 2..4, Z -3..3, desde Y=0 al sur hasta Y=3 al norte. Landing superior X 2..4, Z -4..-3. Falta el tramo Z -5..-4 hasta cabina. Barrera física previa impide intentar saltarlo: no es un desafío de salto. Inspección desde (4,0,3) permite entender la interrupción.
- Rodeo obligatorio inicial: entrada -> (8,0,6) -> (20,0,6). Corredor sur de máquina con anchura libre mínima 2 m.
- Hueco del foso: X 20..28, Z 1..8. Suelo a Y=-2. Barandillas salvo desembarco.
- Escalera fija al foso: X 24..26, Z 8..11; prolongación exterior de servicio dentro de recinto local ampliado hasta Z=12. Inicio (25,0,11), final (25,-2,8). Conectar acceso desde (20,0,9) por suelo de servicio X 20..28, Z 8..12. Sin depender de energía.
- Foso: esquema en (27,-2,6), puente intervenido en (22,-2,4), interruptor mantenimiento en (26,-2,2). Los tres tienen zona de inspección de al menos 2x2 m sin solapamiento con obstáculos. Regreso por la misma escalera, siempre disponible.
- Embarque inferior: X 24..28, Z -1..1, Y=0; acceso desde lado este del foso por X 28..30 y rodeo norte. No atravesar el hueco para alcanzarlo.
- Plataforma de servicio: superficie 3x3 m, centro (26,*, -3), entre Y=0 y Y=3. Embarque inferior por borde sur Z=-1.5, con conexión fija del embarque hasta ese borde.
- Desembarco superior: X 24..28, Z -7..-4.5, Y=3; conexión de borde norte de plataforma Z=-4.5. Puertas de protección o bloqueo de acceso cuando no está presente.
- Pasarela superior: X 9..26, Z -8..-6, Y=3; une cabina y desembarco. Anchura libre 2 m, barandillas y espacio de cámara.
- Seccionador: (19,3,-7), con interacción desde pasarela; distribuidor: (12,3,-7). Indicadores visibles juntos desde (15,3,-7). No obligar a asomarse a un vacío para leerlos.
- Atajo: puerta en (9,3,-8) hacia escalera fija independiente, X 9..11, Z -6..0, descendente de norte a sur. Se desbloquea manualmente desde arriba y queda abierta; devuelve a (10,0,1) por corredor oeste de máquina. No permite subir al inicio.

Las excepciones al rectángulo interior (acceso de escalera del foso) son parte del plano, no errores a resolver inventando geometría. Si las medidas no funcionan con cámara/colisión, registrar una revisión explícita del plano antes de construir más contenido.

## Pistas y visibilidad

Entrada: reconocer cabina y acceso roto, no toda la solución. Foso: esquema y puente requieren observación próxima; cableado físico con identificadores conecta la anomalía con nodo A y nodo T. Pasarela: indicadores permiten contrastar demanda de ensayo con destino archivo; el escáner muestra continuidad oculta, no instrucciones. Terminal dentro de cabina: diagnóstico siempre disponible. No usar color como única distinción.

## Plataforma: puerta de validación separada

Antes de integrar: transporte completo sin deslizamiento, cámara estable, embarques sin salto, llamadas desde ambos extremos, caída y reaparición seguras, ausencia de bloqueos. Si falla, detener integración.

Para evaluar espacio sin plataforma: rampa provisional separada en anexo X 30..34, Z -8..10, con acceso inferior (30,0,9), subida hasta (32,3,-7) y retorno al desembarco (28,3,-6). Identificarla como PROVISIONAL. No cuenta como plataforma probada ni como duración válida de misión.

## Recuperación

Puntos seguros propuestos: entrada; borde superior de escalera de foso; desembarco superior tras alcanzarlo. Caer no borra pistas ni estado lógico. El foso tiene salida fija. Ambos extremos llaman plataforma. El atajo facilita revisitas después del ascenso, pero no debe abrirse desde abajo antes de tiempo. Persistencia y guardado se especificarán y probarán sin cambiar esquemas existentes por comodidad; este documento no autoriza migración.

## Evaluación jugable obligatoria

Recorrido a probar: entrada -> acceso roto -> rodeo -> foso y regreso -> embarque -> pasarela -> controles -> cabina -> atajo. Sin enemigo, extracción definitiva ni contención.

Registrar versión Godot, commit, resolución, dispositivo de entrada y renderer. Observar: destino reconocido sin indicación verbal; acceso roto comprendido sin salto fallido; descenso/regreso sin bloqueo; inspección legible de pistas; cámara que no oculte apoyos o controles; plataforma estable; atajo descubierto y útil. Registrar dudas, caídas, correcciones de cámara, ayudas y fallos. Accesibilidad de destinos sola no aprueba el espacio.

Probar con jugadores que no hayan leído el diseño. Si llegan pero no comprenden conexiones, revisar presentación espacial. Separar resultados de plano inspeccionado, escena ejecutada y experiencia validada manualmente. Aún no hay evidencia de estos últimos.

## Fuera de autorización

Narrativa definitiva, cronología Aster, origen del escáner, extracción protegida, contención, persecución, arte final, eliminación de escenas previas y reescritura de campaña. Estos documentos no autorizan implementación completa.
