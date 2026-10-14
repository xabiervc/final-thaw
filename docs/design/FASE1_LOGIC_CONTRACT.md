# Fase 1 — Contrato lógico

Estado: lógica acordada; documento para revisión previa a implementar. No ejecutado ni validado manualmente. Sustituye las reglas eléctricas de MISSION1_GHOST_PROTOCOL.md para el nuevo prototipo; el prototipo anterior no cumple este contrato.

## Alcance

Solo distribución, protección, diagnóstico y consulta. Sin escena de misión, narrativa definitiva, extracción protegida implementada, contención ni migración de guardado.

## Grafo definitivo

```text
Fuente auxiliar
|-- Emergencia ------------------------------> diagnóstico
|-- Interruptor mantenimiento ---------------> luz de servicio y plataforma
`-- Protección recuperación --> selector exclusivo
                                |-- ENSAYO --------------------> T
                                `-- ARCHIVO --> A --> archivo   |
                                                `-- puente ---> T
                                                               |
                                                seccionador ensayo
                                                               |
                                                     maquinaria
                                                     interbloqueada
```

El puente intervenido es fijo. Ambas rutas hacia maquinaria convergen en T antes del seccionador. Archivo sale de A antes del seccionador. El selector nunca conecta ambos destinos. Es una abstracción lógica, no un simulador eléctrico.

## Estado y salidas

Inicial: mantenimiento apagado; selector ENSAYO; seccionador conectado; protección disponible; sin último fallo.

Fallo presente = selector ARCHIVO y seccionador conectado. Al existir esa condición con protección disponible, dispara inmediatamente. Protección disparada corta toda recuperación. Abrir seccionador o cambiar selector no rearma. Rearmar solo tiene éxito sin fallo presente.

Archivo estable = protección disponible y selector ARCHIVO y seccionador aislado. Mantenimiento no influye. Diagnóstico siempre operativo. Maquinaria nunca arranca: el interbloqueo permanece activo y no es manipulable en este hito.

Registrar por separado destino solicitado, fallo presente, protección, suministro efectivo y último fallo. El diagnóstico conserva el último fallo aunque se corrija y rearme. No confundir demanda registrada antes del disparo con suministro efectivo posterior: tras disparar no hay alimentación de recuperación.

## Operaciones

- set_maintenance(on): solo modifica mantenimiento.
- select(destination): conserva posición solicitada y evalúa protección.
- set_isolated(on): modifica seccionador y evalúa protección. Reconectar ensayo con ARCHIVO seleccionado también dispara.
- rearm(): si hay fallo, rechaza sin cambiar posiciones ni historial; en otro caso deja protección disponible.
- inspect(): siempre disponible físicamente al alcanzar el panel.
- consult(): solo con archivo estable; perder suministro impide nuevas consultas, no borra conocimiento ya adquirido.
- extract(): fuera de implementación. Requerirá suministro estable y autorización externa por definir en guion; no inferir autorización de consultar.

## Diagnósticos

Estado actual y último evento se muestran separados. Sin fallo histórico: «Sin disparos registrados». Selector ENSAYO: «Archivo sin suministro. Destino seleccionado: ensayo». Protección disparada: «Recuperación interrumpida. Último disparo: demanda simultánea en archivo y ensayo». Condición corregida: añadir «Rearme pendiente». Archivo estable: «Alimentación de archivo estable. Consulta disponible». Rearme rechazado: «Persiste la condición de disparo». Nunca indicar qué control accionar.

## Modelo de referencia ejecutable

Python estándar; cada prueba crea un modelo nuevo salvo las secuencias indicadas. Es un oráculo para portar a GDScript, no evidencia de ejecución en Godot.

```python
class Circuit:
    def __init__(self):
        self.m = False
        self.d = 'ENSAYO'
        self.i = False
        self.p = True
        self.last = None

    def fault(self):
        return self.d == 'ARCHIVO' and not self.i

    def evaluate(self):
        if self.p and self.fault():
            self.p = False
            self.last = 'DEMANDA_SIMULTANEA'

    def maintenance(self, on):
        self.m = on

    def select(self, destination):
        assert destination in ('ENSAYO', 'ARCHIVO')
        self.d = destination
        self.evaluate()

    def isolate(self, on):
        self.i = on
        self.evaluate()

    def rearm(self):
        if self.fault():
            return False
        self.p = True
        return True

    def outputs(self):
        return dict(diagnostic=True, maintenance=self.m,
                    archive=self.p and self.d == 'ARCHIVO' and self.i,
                    trial=self.p and not self.i, machine_running=False)

    def snapshot(self):
        return self.m, self.d, self.i, self.p, self.last

# T1: inicial
s = Circuit()
assert s.snapshot() == (False, 'ENSAYO', False, True, None)
assert s.outputs() == dict(diagnostic=True, maintenance=False,
                          archive=False, trial=True, machine_running=False)
# T2: seleccionar archivo dispara y registra
s.select('ARCHIVO')
assert not s.p and s.last == 'DEMANDA_SIMULTANEA'
assert not s.outputs()['archive'] and not s.outputs()['trial']
# T3: aislar elimina fallo, no rearma
s.isolate(True)
assert not s.fault() and not s.p and not s.outputs()['archive']
# T4: rearme correcto
assert s.rearm() and s.outputs()['archive']
assert s.last == 'DEMANDA_SIMULTANEA'
# T5: rearme rechazado con fallo presente
t = Circuit(); t.select('ARCHIVO'); before = t.snapshot()
assert not t.rearm() and t.snapshot() == before
# T6: aislar primero evita disparo
u = Circuit(); u.isolate(True); u.select('ARCHIVO')
assert u.p and u.outputs()['archive'] and u.last is None
# T7: seleccionar ensayo corta archivo; interbloqueo sigue activo
u.select('ENSAYO')
assert not u.outputs()['archive'] and not u.outputs()['machine_running']
u.isolate(False)
assert u.outputs()['trial'] and not u.outputs()['machine_running']
# T8: mantenimiento independiente
s.maintenance(True); s.maintenance(False)
assert not s.outputs()['maintenance']
assert s.outputs()['archive'] and s.outputs()['diagnostic']
# T9: operaciones repetidas preservan coherencia e historial
before = s.snapshot()
for _ in range(10):
    s.isolate(True); s.select('ARCHIVO'); s.maintenance(False)
    assert s.rearm()
assert s.snapshot() == before
# X1: ambos órdenes producen igual estado funcional, no igual historial
v = Circuit(); v.isolate(True); v.select('ARCHIVO')
assert s.outputs() == v.outputs()
assert (s.m, s.d, s.i, s.p) == (v.m, v.d, v.i, v.p)
assert s.last != v.last
# X2: idempotencia también en estado inicial y disparado
for tripped in (False, True):
    w = Circuit()
    if tripped: w.select('ARCHIVO')
    before = w.snapshot()
    for _ in range(10):
        w.maintenance(False); w.isolate(False); w.select(w.d)
        assert w.rearm() == (not tripped)
    assert w.snapshot() == before
# Regresión: reconectar ensayo con archivo seleccionado dispara
v.isolate(False)
assert not v.p and v.last == 'DEMANDA_SIMULTANEA'
```

## Prueba de deducción y evidencia

Esquema: distribución prevista. Puente: discrepancia física. Indicadores: demanda simultánea registrada. Terminal: confirmación del estado, no instrucción. Antes de ayudas explícitas preguntar qué anomalía encontró el jugador, por qué aisló ensayo y qué esperaba observar. Registrar acciones, pistas, ayudas y explicación. Completar probando combinaciones no equivale a comprender; no bloquear soluciones correctas por no haber leído una pista.

Informe separado: inspeccionado / ejecutado (entorno, comando, resultado) / validado manualmente (observaciones). Tests del modelo no validan espacio, persistencia o diversión.
