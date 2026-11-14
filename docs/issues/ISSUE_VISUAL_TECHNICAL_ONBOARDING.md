# [ART/TECH] Onboarding Visual & Técnico: Taxonomia e Anatomia das 16 Raças de Dragões

## 🎯 Objetivo
Estabelecer a identidade visual, anatômica e estrutural das **16 raças anatômicas base** e **80 espécies de dragões** do jogo (16 Raças MBTI × 4 Elementos × 5 Variações), servindo como especificação e guia de referência para modelagem 3D, anatomia modular, rigging, texturização, shaders elementais e animação no Godot 4.3+.

---

## 1. Arquitetura Taxonômica (Matriz 16 × 4 × 5)

Em *Dragons Lair*, cada dragão é montado modularmente a partir de 3 eixos:

1. **16 Raças Base (Definidas pelo MBTI exato do Dragão — Fase 1):**
   Cada tipo de MBTI corresponde a uma silhueta anatômica exclusiva (número de patas, presença ou formato de asas, estrutura de cabeça e cauda).
2. **4 Afinidades Elementais (Definidas pela Rota no Parkour — Fase 2):**
   * **Vento / Raio** *(Caminho das Correntes)*
   * **Fogo** *(Caminho das Brasas)*
   * **Terra** *(Caminho das Raízes)*
   * **Água / Gelo** *(Caminho das Marés)*
3. **5 Variações por Raça (Total: 80 Espécies Catalogáveis):**
   Subespécies definidas pela Identidade (`-A` / `-T`), afinidade secundária ou descobertas na exploração/cruzamento.

---

## 2. Referências Anatômicas Gerais (Silhuetas)

As 16 raças do jogo baseiam-se nas arquiteturas clássicas e exóticas ilustradas nos compêndios de referência (quadrúpedes alados, bípedes wyverns, drakes terrestres sem asas, serpentes emplumadas, hidras multi-cabeças e dragões orientais/aquáticos):

* `assets/references/types_of_dragons_chart.jpg`
* `assets/references/dragons_of_the_world_scale.jpg`
* `assets/references/types_of_dragon_poster.jpg`

---

## 3. Catálogo Completo das 16 Raças (1 por MBTI)

### 🟣 Grupo dos Analistas (`NT` — Foco em Magia, Estratégia e Alcance)
| MBTI | Raça do Dragão | Anatomia Base | Cabeça / Asas / Cauda | Especialidade |
| :--- | :--- | :--- | :--- | :--- |
| **INTJ** | **Draco Arcano** *(Dragon Clássico)* | 4 patas + 2 asas grandes (porte majestoso) | Cabeça `H` • Asa `Fingered` • Cauda `Sword` | Dano elemental massivo à distância e alta precisão mágica. |
| **INTP** | **Lung Celestial** *(Asian Dragon)* | Corpo serpentino longo, sem asas (levitação mágica) | Cabeça `G` • Padrão `F` • Cauda `Heaven` | Regeneração de mana/estamina rúnica e controle de área. |
| **ENTJ** | **Hidra Soberana** *(Hydra)* | Corpo pesado multi-cabeças (2 a 3 cabeças) com asas | Cabeça `B` • Asa `Handed` • Cauda `Morningstar` | Ataques múltiplos simultâneos e intimidação de inimigos. |
| **ENTP** | **Anfíptero Ilusório** *(Amphiptere)* | Corpo serpentino sem patas, sustentado por 2 asas enormes | Cabeça `E` • Asa `Accordion` • Cauda `Dagger` | Esquiva aérea, rajadas rápidas e truques elementais. |

### 🟢 Grupo dos Diplomatas (`NF` — Foco em Vínculo, Suporte e Cura)
| MBTI | Raça do Dragão | Anatomia Base | Cabeça / Asas / Cauda | Especialidade |
| :--- | :--- | :--- | :--- | :--- |
| **INFJ** | **Coatyl Místico** *(Coatyl)* | Serpente emplumada com asas de ave/plumas | Cabeça `J` • Padrão `H` • Cauda `Feather` | Auras de purificação, cura passiva e resistência mágica. |
| **INFP** | **Dragão Feérico** *(Feydragon / Fae)* | Porte esguio com asas estilo mariposa/inseto translúcidas | Cabeça `C` • Padrão `D` • Cauda `River` | Acelera o crescimento de plantas mágicas na fazenda e restaura energia. |
| **ENFJ** | **Serpe Solar** *(Zilant)* | 2 patas dianteiras + asas largas (postura erguida) | Cabeça `K` • Asa `6-Fingered` • Cauda `Heaven` | Buffa o ataque e a defesa do jogador quando lutam próximos. |
| **ENFP** | **Dragonete Etéreo** *(Dragonette)* | Porte médio/ágil, 4 patas leves e asas largas vibrantes | Cabeça `A` • Padrão `F` • Cauda `Fire` | Aumenta a sorte em coletas raras e reduz o custo de impulso no ar. |

### 🔵 Grupo dos Sentinelas (`SJ` — Foco em Defesa, Fazenda e Carga)
| MBTI | Raça do Dragão | Anatomia Base | Cabeça / Asas / Cauda | Especialidade |
| :--- | :--- | :--- | :--- | :--- |
| **ISTJ** | **Basilisco Blindado** *(Basilisk)* | Corpo baixo e largo, 6 patas, couraça dorsal espinhosa | Cabeça `I` • Cauda `Club` (Clava) | Defesa física extrema e imunidade a atordoamento. |
| **ISFJ** | **Dragão Ártico** *(Arctic Dragon)* | Corpo robusto adaptado ao frio, pelagem/escamas densas | Cabeça `D` • Padrão `J` • Cauda `Deep Sea` | Protege o jogador com barreiras de gelo/escudo e resiste a climas hostis. |
| **ESTJ** | **Salamandra de Guerra** *(Salamander)* | 6 patas musculosas + asas médias (tração máxima) | Cabeça `F` • Asa `Handed` • Cauda `Battle` | Maior capacidade de carga da sela (ideal para mineração e colheita). |
| **ESFJ** | **Leviatã das Marés** *(Sea Dragon)* | Corpo aquático com barbatanas dorsais e membrana de planagem | Cabeça `K` • Asa `Rayed` • Cauda `River` | Irrigação automática de áreas da fazenda e deslocamento aquático rápido. |

### 🟡 Grupo dos Exploradores (`SP` — Foco em Velocidade, Crítico e Combate Físico)
| MBTI | Raça do Dragão | Anatomia Base | Cabeça / Asas / Cauda | Especialidade |
| :--- | :--- | :--- | :--- | :--- |
| **ISTP** | **Draco Terrestre** *(Drake)* | 4 patas musculosas, sem asas (saltos gigantes e corrida) | Cabeça `B` • Cauda `Scorpion` (Ferrão) | Dano físico brutal, quebra de armadura e velocidade no solo. |
| **ISFP** | **Wyvern Silvestre** *(Wyvern)* | 2 patas traseiras + asas que funcionam como braços no chão | Cabeça `A` • Padrão `C` • Cauda `Mountain` | Manobrabilidade ágil entre árvores, montanhas e desfiladeiros. |
| **ESTP** | **Wyrm Predador** *(Wyrm)* | Corpo serpentino gigante e ágil, sem patas ou asas | Cabeça `E` • Cauda `Sword` | Emboscadas rápidas, dano crítico alto e perfuração de defesas. |
| **ESFP** | **Lindwurm Veloz** *(Lindwurm)* | Corpo serpentino com 2 patas dianteiras fortes e garras afiadas | Cabeça `H` • Padrão `I` • Cauda `Dagger` | Ataques em sequência velozes e alta taxa de crítico em movimento. |

---

## 4. Módulos Anatômicos & Customização (Modelagem 3D, Rigging e Shaders)

### 4.1. Ovos do Santuário (Fases 1 & 2)
O ovo muda de casca conforme a raça invocada e o elemento da rota do parkour:
* **Fogo:** Escamas sobrepostas e fumaça sutil na fissura.
* **Água:** Casca lisa/cristalina translúcida com partículas de orvalho/gelo.
* **Terra:** Espinhos e casca rochosa/fóssil espessa.
* **Vento:** Filamentos plumosos e vórtice de ar tenue.

### 4.2. Morfologia de Cabeças (`A` a `K`)
Cada raça utiliza um dos arquétipos cranianos como base de *rigging* facial, abertura mandibular e disposição dos chifres.

### 4.3. Anatomia e Padrões de Asas
* **Estrutura Óssea (Rigging de Voo):**
  * *Fingered:* Padrão clássico de quiróptero.
  * *Rayed:* Estilo arraia/marinha para planadores e aquáticos.
  * *6-Fingered:* Alta sustentação para carregar cargas pesadas.
  * *Accordion:* Dobrável e acrobático para manobras evasivas.
  * *Handed:* Apoio terrestre para transição quadrupedal/wyvern.
* **Padrões de Membrana (`A` a `K`) e Paletas Elementais:** Variação de gradientes, transparência e shaders de emissão bioluminescente.
* **Postura Terrestre de Wyverns:** Apoio nas juntas das asas (*ground knuckle-walking*).

### 4.4. Caudas & Armas Naturais
As caudas definem a silhueta, o leme aéreo e o ataque secundário em combate:
* **Elementais:** *Fire Dragon* (I), *Battle Fighter* (II), *River Dragon* (III), *Mountain Beast* (IV), *Deep Sea Monster* (V), *Creature of Heaven* (VI).
* **Bélicas:** *Club Tail* (Clava), *Scorpion Tail* (Ferrão), *Dagger Tail* (Adaga), *Sword Tail* (Espada), *Morningstar Tail* (Maça/Mangual), *Feather Tail* (Plumas/Leme).

### 4.5. Íris e Expressão Ocular (Personalidade & Traço)
* **Predadores / Audaciosos (`SP` / `-A`):** Pupila vertical/fendida agressiva.
* **Protetores / Dóceis (`SJ` / `NF`):** Pupila arredondada com brilho caloroso.
* **Místicos / Arcanos (`NT` / `-T`):** Pupila estrelada/fendida dupla com brilho rúnico.

---

## 📋 Checklist de Entrega / Tasks

- [ ] **Asset Pipeline & Referências**
  - [ ] Armazenar as pranchas em `docs/assets/references/`.
  - [ ] Validar rendering das imagens no README e documentação.
- [ ] **Modelagem 3D & Rigging (Godot 4.3+)**
  - [ ] Definir a malha base para os 6 tipos de corpo (Quadrúpede, Wyvern, Bípede Zilant, Serpentino Lung/Wyrm, 6-patas Basilisco/Salamandra, Hidra).
  - [ ] Criar rigs com compatibilidade modular para troca de cabeças (`A` a `K`) e caudas.
- [ ] **Shaders & Materiais**
  - [ ] Criar shader de membrana alar (subsurface scattering e translucidez).
  - [ ] Criar shader de bioluminescência rúnica e tintura procedural por afinidade elemental.
- [ ] **Integração com `DragonSpeciesData`**
  - [ ] Mapear cenas `.tscn` e texturas `.tres` nos respectivos `DragonSpeciesData` gerados na Issue #1.
