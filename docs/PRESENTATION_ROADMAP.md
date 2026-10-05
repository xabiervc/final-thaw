# Roadmap para una demo visualmente presentable

Este documento describe las tareas necesarias para convertir el esqueleto del slice "Flooded Shelter 2.5D" en una demo presentable.

## 1. Assets de personaje

### Elena
- [ ] Sprite de Elena en vista lateral (cuerpo entero).
- [ ] Animaciones:
  - [ ] `idle` (respiración, ligero movimiento).
  - [ ] `walk_left`, `walk_right` (ciclo de caminata).
  - [ ] `jump` (salto, caída).
  - [ ] `interact` (gesto hacia objeto).
  - [ ] `hurt` / `die` (opcional, si hay tiempo).
- [ ] Luz del Aster (sprite o `PointLight2D` con color cian).

### Civil atrapada
- [ ] Sprite de civil con manta térmica.
- [ ] Animaciones:
  - [ ] `trapped_idle` (temblor, respiración).
  - [ ] `rescued_idle` (alivio, gesto de agradecimiento).
  - [ ] `dead` (opcional).

## 2. Entorno 2.5D

### Fondos (Parallax2D)
- [ ] `Background`: hormigón lejano, maquinaria, tuberías distantes.
- [ ] `Midground`: elementos a profundidad media (conductos, luces, vigas).
- [ ] `Foreground`: barandillas, cables, gotas, vapor frente a cámara.

### Suelo y paredes
- [ ] Texturas de suelo húmedo y paredes de hormigón.
- [ ] Tiles o sprites para plataformas y pasarelas.
- [ ] Variaciones para zonas inundadas vs zonas secas.

## 3. Objetos interactivos

- [ ] `PowerConsole`: sprite de panel con luces indicadoras (apagado/encendido).
- [ ] `ValveStation`: válvula roja con rueda giratoria (cerrado/abierto).
- [ ] `FloodGate`: compuerta metálica (cerrada/abierta).
- [ ] `ShelterLight`: luz de emergencia (apagada/ámbar).

## 4. Iluminación y atmósfera

- [ ] `CanvasModulate` para tono general frío (azul-gris).
- [ ] `PointLight2D` en:
  - [ ] Luces de techo (ámbar cuando hay energía).
  - [ ] Luz del Aster (cian, sigue a Elena).
  - [ ] Consola y válvulas (destellos al interactuar).
- [ ] Sombras suaves en personajes y objetos clave.

## 5. Efectos visuales (VFX)

- [ ] Lluvia fina en primer plano (`GPUParticles2D`).
- [ ] Goteo desde tuberías y techo.
- [ ] Vapor/niebla en zonas inundadas.
- [ ] Destellos en interacciones (consola, válvulas, compuerta).
- [ ] Pequeñas partículas al saltar o caer al agua.

## 6. UI y feedback

- [ ] Mejorar el HUD:
  - [ ] Barra de oxígeno visual (no solo texto).
  - [ ] Icono de objetivo más claro.
  - [ ] Indicador de estado de la civil (icono + texto).
- [ ] Feedback de interacción:
  - [ ] Pequeño texto flotante al interactuar.
  - [ ] Sonido o destello al activar objetos.

## 7. Audio (opcional pero muy recomendable)

- [ ] Ambiente:
  - [ ] Sonido de lluvia y goteo.
  - [ ] Zumbido de maquinaria y luces.
- [ ] SFX:
  - [ ] Pasos de Elena (suelo húmedo / metálico).
  - [ ] Interacción con consola y válvulas.
  - [ ] Compuerta abriéndose.
  - [ ] Aviso de oxígeno bajo.
- [ ] Música:
  - [ ] Tema tenso y frío para el refugio.
  - [ ] Cambio sutil al rescatar a la civil o completar el nivel.

## 8. Orden sugerido de trabajo

1. **Bloquear gameplay primero:**
   - Asegurar que movimiento, interacción, oxígeno y win/lose funcionan bien.
2. **Assets clave de personaje:**
   - Elena con al menos `idle`, `walk` y `jump`.
   - Civil con `trapped` y `rescued`.
3. **Entorno básico:**
   - Tres salas reconocibles (energía, válvulas, rescate).
   - Parallax con al menos dos capas.
4. **Iluminación y VFX mínimos:**
   - Luces de emergencia, Aster, lluvia y goteo.
5. **UI y audio:**
   - HUD claro y SFX básicos.
6. **Pulido final:**
   - Ajustar ritmo, dificultad y legibilidad.

## 9. Criterio de "demo presentable"

Una demo se considera presentable cuando:
- Un jugador nuevo entiende en menos de 1 minuto qué debe hacer.
- El refugio se siente húmedo, oscuro y tenso.
- Elena y la civil son visualmente distinguibles y expresivas.
- Las decisiones (energía, válvulas, rescate) se notan en el entorno y en el resumen final.
- No hay bugs que rompan la progresión (quedarse atascado, oxígeno que no baja, etc.).

## 10. Siguientes slices (fuera de esta demo)

- Slice de Marcus en combate beat 'em up 2D.
- Escena de transición entre slices con diálogo y consecuencias.
- Integración con sistema de guardado global y árbol de decisiones.
