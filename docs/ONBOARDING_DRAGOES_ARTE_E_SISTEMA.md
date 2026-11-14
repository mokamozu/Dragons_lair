# Onboarding de Arte, Anatomia e Geração Modular de Dragões

**Projeto:** Dragons Lair  
**Engine:** Godot 4.3+  
**Objetivo:** Guia de arte e dados para implementar 80 dragões (4 tipos x 4 classes MBTI x 5 variações) de forma coesa, modular e fiel ao conceito visual do projeto.

> As 12 imagens de referência recebidas não foram copiadas para este repositório porque não há autorização para redistribuí-las. As descrições e convenções abaixo preservam o guia; consulte as imagens originais localmente. Antes de publicar imagens em `docs/assets/references/`, confirme os direitos de redistribuição.

## 1. Arquitetura modular

Para viabilizar 80 espécies únicas em 3D no Godot sem modelar 80 esqueletos do zero, os dragões devem ser montados por meio de peças modulares e shaders/texturas controlados por um `DragonSpeciesData` (Resource):

1. Corpo-base e silhueta: definidos pelo tipo elemental obtido no parkour.
2. Cabeça, olhos e padrão das asas: definidos pela classe MBTI.
3. Anatomia da asa, ponta da cauda e textura do ovo: definidos pela variação de 1 a 5.

## 2. Modulos visuais

### Módulo A: Ovos de dragão

O visual dos ovos no Santuário do Mago e no inventário deve variar por tipo elemental e variação.

| Tipo | Direcao visual |
|---|---|
| Fogo (Draco) | Casca escamosa avermelhada e pontiaguda ou obsidiana negra brilhante. |
| Vento (Serpe) | Casca perolada com escamas leves sobrepostas ou ovalada, lisa e pálida. |
| Terra (Wyvern) | Casca rochosa cinza-bruta, verde-musgo manchada ou envolta em raízes/fibras. |
| Água/Gelo (Leviata) | Escamas rígidas azul-turquesa ou azul-celeste com veios líquidos. |

### Módulo B: Silhueta corporal e tipos elementais

| Tipo elemental | Arquetipo anatomico | Postura e locomocao | Proporcao e escala |
|---|---|---|---|
| Serpe das Nuvens (Vento/Raio) | Amphiptere, Coatl ou Feydragon: corpo esguio e aerodinâmico, membros reduzidos ou asas dominantes, antenas/fitas sensoriais. | Postura leve e erguida, pescoço alongado e planagem constante com mínimo esforço. | Médio porte, envergadura muito larga em relação à massa corporal. |
| Draco Vulcânico (Fogo) | Dragão clássico com quatro patas e duas asas, peitoral robusto e musculatura densa. | Quadrúpede firme no solo e decolagem explosiva. | Grande porte, equilibrado entre força terrestre e voo. |
| Wyvern da Montanha (Terra) | Wyvern, Drake ou Basilisk: duas patas traseiras poderosas; asas usadas como apoios dianteiros no chão. | Caminha apoiado nos pulsos das asas, com pescoço curto e blindado. | Porte massivo e pesado, cauda espessa para contrapeso. |
| Leviata das Marés (Água/Gelo) | Sea Dragon, Sea Orc ou Asian Dragon: corpo serpentino alongado, barbatanas dorsais e membranas hidrodinâmicas. | Ondulação fluida no ar e na água, com curvas fechadas em alta velocidade. | Corpo muito longo e flexível, com baixo arrasto aerodinâmico/aquático. |

### Módulo C: Cabeças e olhos — classes MBTI

A classe MBTI define a expressão facial, o formato do crânio e o tipo de íris/pupila.

| Classe | Grupos MBTI | Cabecas | Olhos e expressao |
|---|---|---|---|
| Soberana (Analistas) | NT: INTJ, INTP, ENTJ, ENTP | Modelos B, F e H; crânios angulares, focinho alongado e afilado, chifres retos apontados para trás. | Pupilas verticais finas ou concêntricas; verde felino, azul concêntrico ou dourado reptiliano; foco e inteligência fria. |
| Etérea (Diplomatas) | NF: INFJ, INFP, ENFJ, ENFP | Modelos C, G e J; crânios ornamentados com cristas em leque, barbatanas faciais ou barbilhões sensoriais. | Íris luminosas e suaves, azul-violeta claro, branco glacial ou pupila redonda; empatia e misticismo. |
| Bastião (Sentinelas) | SJ: ISTJ, ISFJ, ESTJ, ESFJ | Modelos A e I; mandíbula pesada, crânio arredondado e blindado, placas ósseas sobre os olhos. | Pupilas redondas firmes ou em cruz; âmbar, amarelo-ouro ou olho escuro; estabilidade e vigilância. |
| Predadora (Exploradores) | SP: ISTP, ISFP, ESTP, ESFP | Modelos D, E e K; focinho curto e agressivo, dentes expostos, língua bífida, guelras/abas laterais e chifres irregulares. | Alto contraste e alerta: vermelho-rubi, laranja com pupila em cruz ou multipupila; reflexos e imprevisibilidade. |

### Módulo D: Estrutura óssea e padrões de asas

1. **Fingered (dedos articulados):** asa clássica de morcego/draco; padrão para a classe Bastião (SJ) e o Draco.
2. **Rayed (raios paralelos):** membrana sustentada por espinhos longos; padrão para o Leviata.
3. **6-Fingered (seis dedos):** alta sustentação e planagem; padrão para a Serpe.
4. **Accordion (sanfonada):** dobra-se rente ao corpo para mergulhos rápidos; padrão para a classe Predadora (SP).
5. **Handed (garras livres no pulso):** permite escalar penhascos e agarrar; padrão para o Wyvern.

Padrões de camuflagem e runas:

- A e I: listras agressivas e contrastes vermelho/preto para dragões de Fogo e Predadores (SP).
- C, G e K: tons terrosos, ocelos solares e degradês dourados para dragões de Terra e Sentinelas (SJ).
- D, F e H: padrões geométricos, simetria de mariposa/borboleta e bioluminescência para dragões de Vento e Diplomatas (NF).
- B, E e J: ondas fluidas, listras zebra/pelágicas e tons escuros/glaciais para dragões de Água e Analistas (NT).

As silhuetas vistas de cima devem orientar os ícones do Bestiário/UI e o campo de visão da câmera de voo, para garantir leitura imediata.

### Módulo E: Pontas de cauda — cinco variações de espécie

| Variacao | Linhagem | Anatomia da cauda | Bonus funcional |
|---|---|---|---|
| 1 | Pura/Clássica | Dagger Tail ou ponta de lança simples e equilibrada. | Atributos balanceados, sem penalidades. |
| 2 | Blindada/Colosso | Clava ou estrela da manhã com esfera óssea e espinhos. | +15% Defesa Física; ataque de cauda causa atordoamento. |
| 3 | Alada/Veloz | Plumas ou nadadeira dupla para leme aéreo. | +15% Velocidade de Voo e agilidade em curvas. |
| 4 | Rúnica/Mística | Fitas longas flutuantes e marcas brilhantes. | +15% Poder Elemental e regeneração de energia. |
| 5 | Ancestral/Alfa | Lâmina serrilhada longa ou ferrão venenoso/elemental. | +10% Crítico e habilidade passiva exclusiva da espécie. |

## 3. Leis de coesão

1. **Silhueta:** a câmera de voo fica atrás e acima do dragão. Asas e caudas têm prioridade visual sobre detalhes pequenos no peito.
2. **Paleta elemental e classe:**
   - Elemento: Fogo = vermelho/carvão/ouro; Vento = branco/ciano/prata; Terra = verde-musgo/ocre/pedra; Água = azul-profundo/turquesa/índigo.
   - Classe: Analistas (NT) = violeta/azul-elétrico; Diplomatas (NF) = esmeralda/rosa-etéreo; Sentinelas (SJ) = âmbar/bronze; Exploradores (SP) = carmesim/laranja-neon.
3. **Modularidade Godot 4:** evitar 80 cenas independentes. Usar quatro rigs-base (`rig_serpe.tscn`, `rig_draco.tscn`, `rig_wyvern.tscn`, `rig_leviata.tscn`) com `BoneAttachment3D`, `BlendShapes` ou troca de malhas para cabeça, asa e ponta da cauda.
4. **Nomenclatura:** IDs seguem `{tipo}_{classe}_{variacao}`, por exemplo `fogo_nt_05` para Draco Vulcânico Analista Ancestral.
5. **Continuidade ovo-filhote-adulto:** a paleta e a textura do ovo devem corresponder às cores-base do dragão que dele eclode.

## 4. Referencias visuais recebidas

As imagens não estão distribuídas com este repositório. A lista abaixo preserva os nomes planejados caso a inclusão seja autorizada no futuro:

```text
docs/assets/references/
├── ref_01_wyvern_posture_study.png
├── ref_02_dragon_eggs.png
├── ref_03_dragon_heads_ak.png
├── ref_04_wing_patterns_ak.png
├── ref_05_topdown_silhouettes.png
├── ref_06_dragon_eyes.png
├── ref_07_types_of_dragons.png
├── ref_08_dragon_tails_color.png
├── ref_09_dragon_tails_catalogue.png
├── ref_10_dragons_of_the_world_scale.png
├── ref_11_types_of_dragon_alt.png
└── ref_12_wing_anatomy.png
```
