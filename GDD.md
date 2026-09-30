# FINAL THAW — Game Design Document (Award-Quality Standard)

## Vision Statement

**FINAL THAW** es un action-adventure isométrico para un jugador que alterna entre dos protagonistas: Elena Vast, científica atmosférica, y Marcus Reyes, ex oficial de policía. Juntos deben decidir si salvar un clima colapsado a costa de permitir que una corporación controle quién merece ser salvado.

**Ambición:** Competir en The Game Awards, D.I.C.E. Awards, BAFTA Games Awards y Game Developers Choice Awards en categorías de Narrativa, Diseño de Juego, Dirección Artística, Audio y Accesibilidad.

**Duración:** 5–7 horas de experiencia pulida, sin filler.

---

## Pilares de Diseño

### 1. Narrativa Madura y Específica
- Elena y Marcus son personas concretas, no arquetipos
- Su relación evoluciona mediante acción compartida, no declaraciones
- Helix es un sistema racional, no un villano de caricatura
- El colapso climático es la condición, no el tema de cada línea
- La elección final no tiene opción "buena": solo tradeoffs costosos

### 2. Jugabilidad Intencional y Legible
- Cada mecánica existe por razones temáticas y de diseño
- Sistemas deterministas: nada aleatorio, todo aprendido
- Puzzles de Elena son sistemas atmosféricos, no lock-and-key
- Combate de Marcus es táctico, ambiental, con peso
- El switching entre personajes crea estrategias emergentes

### 3. Dirección Artística Funcional
- Estética isométrica 2D/2.5D estilizada, no fotorrealista
- Paleta de colores que refleja tono emocional y degradación ambiental
- Siluetas de personajes instantáneamente legibles
- UI diegética donde sea posible, minimalista siempre
- Cada frame debe ser screenshot-worthy

### 4. Excelencia Técnica
- Godot 4.x optimizado para 60 FPS en hardware modesto
- Zero tolerancia a softlocks, crashes o saves corruptos
- Checkpoints que nunca atrapan al jugador
- QA exhaustivo: cada camino, cada final, cada estado de contador

### 5. Accesibilidad Integral
- Input remapping completo
- Tamaños de texto: pequeño, normal, grande, extra-grande
- Paletas colorblind-safe e indicadores no basados en color
- Reduced motion / camera shake toggle
- Reduced weather intensity toggle
- Descripciones de audio para información solo visual
- Indicadores visuales para información solo auditiva
- Sin inputs críticos de timing sin opciones de pausa/ralentización
- Todos los diálogos skippables y legibles a ritmo del jugador

---

## Personajes

### Elena Vast
- **Edad:** 34
- **Rol:** Científica atmosférica, creadora del Aster Protocol
- **Arco:** De creer que los datos hablan por sí mismos a entender que las personas deciden qué escuchar
- **Gameplay:** Puzzles de sistemas ambientales, terminales, observación, no combate
- **Contador:** Elena Safety (0–3)

### Marcus Reyes
- **Edad:** 42
- **Rol:** Ex oficial de policía, ahora contractor independiente
- **Arco:** De seguir órdenes a decidir qué tipo de persona quiere ser
- **Gameplay:** Combate beat-'em-up táctico, ambiental, con armas improvisadas
- **Contador:** No tiene contador propio, pero protege a Elena y a civiles

### Helix Dynamics (Antagonista Sistémico)
- Corporación que desarrolló el Aster Protocol junto a Elena
- Racional, no malvada: maximiza supervivencia bajo restricción de recursos
- Controla distribución del protocolo para mantener poder
- El Commander es un empleado competente, no un monstruo

---

## Estructura Narrativa

### Act I: Separación (Fases 1–8)
**Tema:** Desconfianza y supervivencia individual

- Elena escapa con el prototipo Aster
- Marcus persigue objetivos separados
- Ambos descubren que Helix ocultó un método viable de estabilización
- Primer encuentro: tregua temporal para escapar

### Act II: Cooperación (Fases 9–12)
**Tema:** Confianza construida mediante acción

- Elena y Marcus viajan juntos hacia Final Thaw Station
- Calibran el Aster Protocol
- Descubren evidencia de que Helix fabricó el fallo del test
- Elección preliminar: preservar o borrar evidencia

### Act III: The Final Thaw (Fases 13–15)
**Tema:** Tradeoffs y responsabilidad

- Asalto a Final Thaw Station
- Boss final coordinado entre Elena y Marcus
- Elección final que sobrescribe la preliminar
- Tres finales determinados por contadores y elección

---

## Sistemas de Consecuencia

### Contadores Visibles

| Contador | Rango | Inicio | Efecto |
|----------|-------|--------|--------|
| Elena Safety | 0–3 | 3 | Determina si Elena sobrevive intacta |
| Prototype Integrity | 0–3 | 3 | Determina eficacia del Aster Protocol |
| Civilian Aid | 0–10 | 0 | Determina si comunidades reciben datos |

### Reglas de Diseño

1. **Siempre visibles:** El jugador nunca debe adivinar el estado
2. **Siempre significativos:** Cada cambio debe tener consecuencia narrativa
3. **Deterministas:** Nada aleatorio, todo telegrafiado y aprendido
4. **Recuperables:** El jugador debe poder entender cómo recuperar si es posible
5. **Accesibles:** Información disponible mediante múltiples canales (visual, audio, texto)

---

## Finales

### Fragile Thaw (Prioritario)
**Condición:** `elena_safety <= 1` O `prototype_integrity <= 1`

- El protocolo activa imperfectamente
- Tormentas disminuyen pero no cesan
- Elena está herida o el prototipo dañado
- Recuperación es posible pero más difícil
- **Tema:** Supervivencia con costo alto

### Public Thaw
**Condición:** `civilian_aid >= 4` Y `prototype_integrity >= 2` Y `evidence_choice == "preserve"`

- El protocolo activa completamente
- Helix pierde legitimidad pública
- Comunidades reciben datos de estabilización
- Recuperación comienza como recurso compartido
- **Tema:** Victoria colectiva con transparencia

### Guarded Thaw
**Condición:** Todo lo demás

- El protocolo activa
- Clima se estabiliza
- Helix controla acceso a tecnología
- Zonas protegidas prosperan, otras permanecen vulnerables
- **Tema:** Estabilidad con jerarquía

---

## Diseño de Niveles

### Principios Generales

1. **Legibilidad primero:** El jugador debe entender el espacio en 5 segundos
2. **Rutas claras:** Camino principal siempre identificable
3. **Opcionales significativos:** Rescates y secretos deben valer la pena
4. **Checkpoints generosos:** Muerte no debe sentirse como castigo severo
5. **Accesibilidad espacial:** Sin saltos frame-perfect, timing generoso

### Estructura por Fase

| Fase | Tipo | Duración | Enemigos | Puzzles | Boss |
|------|------|----------|----------|---------|------|
| 2 | Puzzle (Elena) | 15 min | 0 | 4 salas | No |
| 4 | Combate (Marcus) | 20 min | Scavengers, Enforcers | 0 | No |
| 5 | Minijuego | 5 min | 0 | 1 puzzle UI | No |
| 6 | Puzzle (Elena) | 25 min | 0 | Agua, bombas, rescates | No |
| 7 | Combate (Marcus) | 30 min | Marksmen, Enforcers | 0 | Riot Commander |
| 8 | Joint (Marcus controla) | 20 min | Scavengers | Terminales | No |
| 9 | Minijuego | 10 min | 0 | Circuito | No |
| 10 | Puzzle (Elena) | 30 min | 0 | Agua, plataformas, grúas | No |
| 11 | Combate (Marcus) | 35 min | Shields, todos tipos | 0 | Transport Captain |
| 12 | Joint (switching libre) | 25 min | Todos tipos | 3 rooms combinadas | No |
| 13 | Joint (nivel largo) | 40 min | Todos tipos | Sistemas combinados | No |
| 14 | Boss Final | 15 min | Commander + adds | 3 calibraciones | Sí |
| 15 | Epílogo | 10 min | 0 | 0 | No |

---

## Diseño de Combate

### Principios

1. **Telegrafía clara:** Cada ataque enemigo debe ser legible antes de impactar
2. **Contra-juego existente:** Cada enemigo tiene debilidad explotable
3. **Sin daño inevitable:** El jugador siempre tiene opción de evitar daño
4. **Ambiental significativo:** Objetos lanzables, cobertura, terreno importan
5. **Determinista:** Nada de RNG en daño, timing o comportamiento

### Tipos de Enemigo

| Enemigo | Salud | Daño | Velocidad | Debilidad |
|---------|-------|------|-----------|-----------|
| Scavenger | Baja | Bajo | Rápida | Flanqueo, throws |
| Enforcer | Alta | Medio | Lenta | Flanco, ambiente |
| Marksman | Baja | Alto | Media | Cobertura sólida |
| Shield | Media | Medio | Lenta | Flanco, stun ambiental |

### Boss Design

**Riot Commander (Fase 7):**
- Shield bash telegrafiado
- Bloqueo frontal
- Tear gas area denial
- Punto débil trasero visible
- Enrage en threshold de salud

**Transport Captain (Fase 11):**
- Ground slam con shockwave evitable
- Cargo throw telegrafiado
- Reinforcement call fijo
- Interacción con grúa opcional pero útil

**Helix Commander (Fase 14):**
- Energy blast dodgeable
- Shield barrier temporal
- Reinforcement call con enemigos existentes
- Reactor sabotage con counterplay claro
- Tres ventanas de vulnerabilidad tras calibraciones de Elena

---

## Diseño de Puzzles

### Principios

1. **Solución fija:** Nada aleatorizado, todo aprendido
2. **Legible:** El jugador debe entender las reglas sin texto extenso
3. **Reset rápido:** Fallo no debe costar más de 10–15 segundos
4. **Accesible:** Sin timing frame-perfect, ventanas generosas
5. **Temático:** Puzzles son sistemas atmosféricos, no abstractos

### Tipos de Puzzle

| Tipo | Ejemplo | Fases |
|------|---------|-------|
| Terminal sequence | Conectar power grid | 2, 6, 10 |
| Moving platform | Timing de ciclo fijo | 2, 10 |
| Water redirect | Válvulas y bombas | 6, 10 |
| Circuit rotation | Reconectar path | 9 |
| Power routing | Decidir qué recibe energía | 10, 13 |
| Security disable | Timing bajo presión | 12, 14 |
| Lighting control | Manipular visibilidad | 12 |

---

## UI/UX

### Principios

1. **Minimalista:** Solo información necesaria
2. **Diegética:** Integrada en el mundo cuando sea posible
3. **Legible:** Contraste alto, tamaños ajustables
4. **Accesible:** Múltiples canales de información
5. **Skippable:** Diálogos y cinemáticas nunca bloquean gameplay

### HUD

**Siempre visible:**
- Elena Safety (icono + número 0–3)
- Prototype Integrity (icono + número 0–3)
- Civilian Aid (icono + número 0–10)
- Active character indicator (cuando switching está disponible)

**Contextual:**
- Interaction prompt (nombre del objeto + botón)
- Scan highlights (brillo en interactuables cercanos)
- Enemy health bars (solo cuando en combate)
- Timer de oxígeno (solo en sección específica)

**Menús:**
- Pausa con opciones de reanudar, ajustes, salir
- Ajustes con: audio, vídeo, controles, accesibilidad
- Mapa solo en niveles específicos (no en todos)

---

## Accesibilidad

### Opciones Obligatorias

**Visuales:**
- Tamaño de texto: Pequeño, Normal, Grande, Extra-Grande
- Modo daltonico: Paletas alternativas
- Reduced weather intensity: Menos partículas de nieve/lluvia
- High contrast UI: Bordes más marcados

**Auditivas:**
- Subtítulos: Siempre on, tamaño ajustable
- Indicadores visuales para audio crítico
- Audio descriptions toggle (si hay voz)

**Motoras:**
- Input remapping completo
- Toggle para mantener botón vs pulsar
- Timing windows ajustables (Normal, Generoso, Muy Generoso)
- Reduced camera shake

**Cognitivas:**
- Hint system opcional
- Objective tracker siempre visible
- Tutorial re-jugable desde menú
- Sin secciones sin checkpoint por más de 5 minutos

### Testing

- Testear con jugadores discapacitados reales
- Documentar todos los escenarios de accesibilidad en QA checklist
- Nunca bloquear progreso detrás de barreras de accesibilidad

---

## Audio

### Principios

1. **Funcional:** Cada sonido debe informar gameplay
2. **Atmosférico:** Música y ambiente refuerzan tono
3. **Minimalista:** Silencio es herramienta válida
4. **Accesible:** Información auditiva tiene equivalente visual

### Diseño Sonoro

**Ambiente:**
- Viento, tormenta, maquinaria: siempre presente pero no intrusivo
- Cambios de estado (power on/off, water rising) tienen firma sonora clara

**Combate:**
- Cada ataque tiene sonido distintivo
- Hit feedback claro pero no excesivo
- Enemy telegraphs tienen audio cue

**Música:**
- Minimalista, ambiental
- No domina escenas narrativas
- Silencio en momentos clave

---

## Rendimiento Técnico

### Objetivos

- **FPS:** 60 estables en hardware modesto (GTX 1050 / equivalente)
- **Load times:** < 3 segundos entre niveles
- **Save size:** < 100 KB por save
- **Memory:** < 512 MB RAM en uso

### Optimización

- Usar Godot Profiler para identificar bottlenecks
- Limitar partículas y efectos en secciones largas
- Pooling de enemigos y proyectiles
- Carga asíncrona de assets entre niveles

---

## QA y Release

### Checklist de Calidad

**Antes de cada commit:**
- [ ] No parser errors en Godot
- [ ] No softlocks en nivel afectado
- [ ] Save/load funciona después del cambio
- [ ] Contadores se actualizan correctamente
- [ ] Accesibilidad no está rota

**Antes de release:**
- [ ] Todos los finales alcanzables y probados
- [ ] Todos los niveles completados sin bugs
- [ ] Todos los enemigos y bosses probados
- [ ] Todos los puzzles solubles y legibles
- [ ] Todas las opciones de accesibilidad funcionales
- [ ] Export a Windows probado y funcionando
- [ ] Zero crashes en 10+ playthroughs completos

### Documentación

- `docs/qa_checklist.md`: Lista exhaustiva de tests
- `docs/qa_results.md`: Resultados reales de testing
- `docs/release_checklist.md`: Pasos de release
- `README.md`: Instrucciones de instalación y ejecución

---

## Referencias de Calidad

Estudiar estos títulos como benchmark:

**Narrativa:** What Remains of Edith Finch, Firewatch, Disco Elysium, The Last of Us Part II
**Gameplay:** Hades, Celeste, Dead Cells, Return of the Obra Dinn
**Arte:** Gris, Okami, Cuphead, Journey, Inside
**Audio:** Hellblade: Senua's Sacrifice, The Last of Us Part II, Returnal
**Accesibilidad:** The Last of Us Part II, Celeste, Forza Horizon 5

**FINAL THAW debe ser digno de estar junto a estos títulos.**

---

## Estándar Final

Antes de release, preguntar: "¿Mostraría esto orgullosamente a los desarrolladores de [título de referencia]?"

Si la respuesta es no, iterar hasta que sea sí.
