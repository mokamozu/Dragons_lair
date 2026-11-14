# [FEATURE/CORE] Sistema de Voo Fluido: Momentum, Carga de Velocidade, Impulso e Aerodinâmica

## 🎯 Objetivo
Substituir a movimentação aérea linear básica do `DragonController` por um **sistema de física e mecânica de voo 3D fluida e aerodinâmica**, incorporando **mergulho com carga de velocidade cinética**, **conversão de momentum em altitude (zoom climb)**, **impulsos de batida (flap boost)**, **bancagem orgânica (roll/bank)**, **freio aéreo (air brake)** e **câmera dinâmica com FOV adaptativo**.

O comportamento físico deve se integrar diretamente aos atributos da taxonomia de dragões (`flight_speed_multiplier`, `turn_agility_multiplier`, `flight_stamina_cost_multiplier`).

---

## 🦅 Especificação das Mecânicas de Voo

### 1. Física e Conservação de Momentum
* **Planagem Base (Cruzeiro):** Deslocamento suave com sustentação natural a velocidade constante e gasto mínimo de estamina.
* **Mergulho (Dive) & Carga de Velocidade:**
  * Inclinar o nariz para baixo ($\text{pitch} < 0$) acelera o dragão progressivamente de $14\,m/s$ até a velocidade terminal ($35-42\,m/s$).
  * Acúmulo de energia cinética no medidor interno `kinetic_charge`.
* **Ascensão / Conversão (Zoom Climb):**
  * Inclinar o nariz para cima ($\text{pitch} > 0$) consome o `kinetic_charge` acumulado e impulsiona o dragão verticalmente, permitindo alcançar picos e ilhas flutuantes.
* **Estol (Stall Recovery):**
  * Caso o jogador tente subir sem velocidade suficiente ($v < 5\,m/s$), o dragão entra em estol e perde altitude até que o jogador aponte o nariz para frente/baixo.
* **Impulso de Batida (Flap Boost):**
  * Pressionar ação de salto no ar consome estamina para gerar um impulso instantâneo para frente e para cima (+aceleração súbita).
* **Freio Aerodinâmico (Air Brake):**
  * Tecla de ré/freio abre asas em concha, desacelera rapidamente e permite curvas fechadas de $180^\circ$.

---

## 🎥 Câmera Dinâmica & Game Feel (Godot 4)
* **FOV Dinâmico:** Expande suavemente de $70^\circ$ (repouso) para $90^\circ+$ durante velocidade terminal.
* **Distância do SpringArm:** Afasta a câmera dinamicamente em alta velocidade e fecha em manobras lentas.
* **Bancagem Suave (Roll):** Rotação no eixo Z da malha visual com inclinação de até $60^\circ$ acompanhando o raio das curvas.
* **VFX & SFX de Velocidade:**
  * Linhas de vento nas pontas das asas (`GPUParticles3D` / *Ribbon Trail*).
  * Loop de áudio de vento com *pitch* e volume proporcionais à magnitude do vetor de velocidade.

---

## 🛠️ Arquitetura Técnica Proposta

### 1. Refatoração de Scripts
```text
godot_project/
└── src/
    ├── dragon/
    │   ├── dragon_controller.gd       # Controlador principal atualizado com a FSM de voo
    │   └── flight/
    │       ├── dragon_flight_physics.gd # Módulo de cálculo vetorial (Thrust, Lift, Drag, Momentum)
    │       └── flight_camera_effects.gd # Controlador de FOV, tremores e efeitos de velocidade
    └── camera/
        └── third_person_camera.gd     # Suporte a transições elásticas de distância e rotação
```

### 2. Integração com Stats da Espécie
* **Serpe (Vento):** Menor consumo de estamina no impulso, velocidade terminal mais alta ($42\,m/s$).
* **Draco (Fogo):** Aceleração de mergulho agressiva e maior impacto de pouso.
* **Wyvern (Terra):** Maior sustentação em baixa velocidade e decolagem potente.
* **Leviatã (Água):** Planagem rente ao mar/rios sem perda de velocidade (*efeito solo*).

---

## 📋 Checklist de Implementação

- [ ] **Módulo Físico (`dragon_flight_physics.gd`)**
  - [ ] Implementar cálculo vetorial de aceleração, mergulho e conversão de momentum em altitude.
  - [ ] Implementar sistema de acúmulo de `kinetic_charge`.
  - [ ] Implementar detecção de estol (*stall*) e perda de sustentação em baixa velocidade.
  - [ ] Implementar impulso de batida ativa (*flap boost*) com consumo de estamina.
  - [ ] Implementar freio aerodinâmico (*air brake*).
- [ ] **Controles e Animação Visual**
  - [ ] Atualizar `dragon_controller.gd` para utilizar o novo módulo físico quando montado e voando.
  - [ ] Implementar inclinação lateral suave (*roll/banking*) baseada na velocidade e esterçamento.
  - [ ] Ajustar pitch do corpo acompanhando a trajetória de subida e descida.
- [ ] **Câmera & Feedback Sensorial**
  - [ ] Atualizar `third_person_camera.gd` com FOV adaptativo baseado na velocidade.
  - [ ] Adicionar partículas de trilha de vento (*Ribbon Trail*) nas pontas das asas do dragão.
  - [ ] Conectar o gerador de áudio dinâmico de vento.
- [ ] **Testes e Polimento**
  - [ ] Validar transição suave: Chão $\rightarrow$ Decolagem $\rightarrow$ Planagem $\rightarrow$ Mergulho $\rightarrow$ Pouso.
  - [ ] Validar que nenhum teste existente de prólogo seja quebrado.

---

## 🎯 Critérios de Aceite
1. O dragão ganha velocidade expressiva ao mergulhar e consegue converter essa velocidade em ganho de altitude ao puxar o nariz para cima.
2. O FOV da câmera e o afastamento reagem em tempo real à velocidade sem engasgos ou tremores.
3. As curvas aéreas inclinam organicamente o corpo do dragão (roll) proporcionalmente à velocidade.
4. O consumo de estamina respeita as taxas configuradas no `DragonStats` da espécie vinculada.
