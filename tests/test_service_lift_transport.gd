En tests/test_service_lift_transport.gd, cambiar dos valores de frames para que el rider no recorra 17 m y caiga por el borde norte del rellano superior:

1) Desembarque:
- Antes: await _frames(130)
- Después: await _frames(30)

2) Volver a subir:
- Antes: await _frames(110)
- Después: await _frames(25)

No se modifica service_lift.gd ni lift_test_rig.gd.