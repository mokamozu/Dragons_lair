# DRAGONS LAIR

## Game Design Document (GDD)
**Versão:** 0.1 — Documento inicial de produção
**Status:** Em desenvolvimento
**Engine:** Godot 4.3+
**Gênero:** Simulação de Fazenda Medieval / RPG de Ação / Exploração / Crafting
**Perspectiva:** 3D em terceira pessoa
**Plataforma-alvo:** A definir
**Jogadores:** Single-player (proposta inicial a confirmar)

---

# 1. VISÃO GERAL DO PROJETO

## 1.1 Conceito
Dragons Lair é um jogo de aventura e simulação medieval em mundo fantástico, no qual o jogador estabelece um vínculo com um dragão, constrói e administra uma propriedade rural, explora regiões desconhecidas e enfrenta criaturas utilizando habilidades próprias e de seu companheiro.

A experiência combina atividades tranquilas de gerenciamento e cultivo com momentos de exploração, combate e progressão de RPG.

O dragão não é apenas uma montaria ou ferramenta de combate: ele é o principal companheiro do jogador e participa diretamente de praticamente todas as atividades importantes do jogo.

## 1.2 Pilares de design
O desenvolvimento deverá respeitar quatro pilares fundamentais:

**1. Companheirismo**

- Construção de um relacionamento entre jogador e dragão.
- Personalidade e características individuais.
- Evolução baseada em cuidado, treinamento e experiências.
- Participação ativa do dragão na aventura.
**2. Liberdade de exploração**

- Mundo com diferentes biomas.
- Ilhas flutuantes, cavernas e montanhas.
- Exploração aérea e terrestre.
- Descoberta de recursos e criaturas.
**3. Construção e administração**

- Desenvolvimento de uma fazenda medieval.
- Cultivo de ingredientes mágicos.
- Criação de alimentos e equipamentos.
- Expansão das instalações e capacidade produtiva.
**4. Progressão de RPG**

- Atributos e habilidades.
- Especializações elementais.
- Equipamentos e melhorias.
- Combate e evolução do personagem e do dragão.

## 1.3 Proposta de experiência
O jogador deverá sentir que está construindo uma relação verdadeira com seu dragão enquanto desenvolve um lugar próprio no mundo.

A fazenda representa segurança e progresso. A exploração representa descoberta e aventura. O dragão conecta essas duas experiências.

---

# 2. MECÂNICA ASSINATURA: RITUAL DO PRIMEIRO VÍNCULO

## 2.1 Apresentação
O jogo começa com o jogador sendo conduzido ao Santuário dos Ovos, onde participará de uma cerimônia especial.

Antes de receber seu primeiro dragão, o jogador será submetido a duas avaliações:

- Etapa A: Teste de Personalidade.
- Etapa B: Teste de Habilidade.
O resultado determinará as características iniciais do companheiro.

## 2.2 Etapa A — Teste de Personalidade
O jogador responderá a quatro dilemas interativos.

Cada resposta contribuirá para uma pontuação de afinidade elemental.

As quatro afinidades disponíveis são:

ElementoArquétipoCaracterísticasFogoOfensivoCoragem, impulsividade e agressividade.TerraGuardiãoProteção, paciência e resistência.VentoExploradorLiberdade, curiosidade e mobilidade.Água/GeloEstrategistaAnálise, controle e planejamento.
### Características dos dragões
**Fogo — Ofensivo**

- Alto dano em área.
- Sopro de fogo contínuo.
- Maior agressividade em combate aéreo.
- Especialização em dano direto.
**Terra — Guardião**

- Defesa elevada.
- Maior capacidade de carga.
- Ataques físicos pesados.
- Especialização em proteção e transporte.
**Vento — Explorador**

- Maior velocidade de voo.
- Menor consumo de estamina durante o planar.
- Manobras aéreas aprimoradas.
- Especialização em exploração.
**Água/Gelo — Estrategista**

- Controle de grupos.
- Lentidão e congelamento.
- Ataques precisos à distância.
- Habilidades de regeneração.

### Regra de determinação
A afinidade com maior pontuação determinará o arquétipo inicial.

**Decisões pendentes:**

- Definir os quatro dilemas.
- Estabelecer a pontuação de cada resposta.
- Definir critérios para empates.
- Determinar se haverá afinidades secundárias.

## 2.3 Etapa B — Teste de Habilidade
Após a avaliação de personalidade, o jogador participará de um desafio prático.

### Desafio proposto
Atravessar uma ponte em processo de desmoronamento enquanto utiliza um estilingue ou arco para acertar alvos.

O percurso também apresentará itens opcionais para coleta.

### Critérios de avaliação
CritérioAtributos influenciadosTempo de conclusãoVelocidade e AgilidadePrecisão dos disparosAtaque e CríticoItens opcionais coletadosCarga e SorteO desempenho determinará os bônus iniciais do dragão.

**Decisões pendentes:**

- Definir pontuações e faixas de desempenho.
- Estabelecer limites para os bônus.
- Determinar se o desafio poderá ser repetido.
- Definir como o sistema evitará penalizar jogadores menos experientes.

## 2.4 Resultado do ritual
Ao concluir as duas avaliações, o jogador receberá seu primeiro dragão.

O companheiro terá:

- Arquétipo elemental.
- Atributos iniciais influenciados pelo teste.
- Habilidades iniciais correspondentes ao elemento.
- Características próprias que serão desenvolvidas durante a aventura.

---

# 3. GAMEPLAY LOOP

## 3.1 Ciclo principal
O jogo será estruturado em quatro atividades interligadas.

### 1. Explorar e voar
O jogador utiliza seu dragão para alcançar novas regiões, ilhas flutuantes, cavernas e montanhas.

### 2. Coletar e combater
Durante a exploração, o jogador enfrenta criaturas e coleta materiais.

Exemplos:

- Escamas.
- Minérios.
- Sementes raras.
- Ingredientes mágicos.
- Materiais de fabricação.

### 3. Cultivar e forjar
Os recursos coletados são utilizados na propriedade.

Atividades:

- Plantar ingredientes mágicos.
- Colher recursos.
- Preparar alimentos.
- Produzir rações especiais.
- Forjar selas e armaduras.

### 4. Evoluir o vínculo
O relacionamento com o dragão progride por meio de atividades compartilhadas.

Exemplos:

- Alimentação.
- Cuidados.
- Exploração.
- Voos.
- Combates.
- Treinamentos.
O fortalecimento do vínculo desbloqueia novas possibilidades de voo e combate.

## 3.2 Relação entre os sistemas
A economia do jogo deverá estimular a integração entre as atividades.

Exemplo de progressão:

Exploração → Coleta de materiais → Produção na fazenda → Fabricação de equipamentos → Melhoria do dragão → Acesso a novas regiões.

Esse ciclo deverá ser a principal estrutura de progressão do jogo.

---

# 4. SISTEMA DE DRAGÕES

## 4.1 Conceito
Os dragões são os principais companheiros do jogador.

Cada dragão possui características relacionadas ao seu elemento e arquétipo.

Seu desempenho depende de atributos, alimentação, equipamentos, treinamento e vínculo.

## 4.2 Afinidades elementais
O sistema inicial contempla quatro arquétipos:

- Fogo.
- Terra.
- Vento.
- Água/Gelo.
Cada arquétipo deverá apresentar diferenças mecânicas reais, evitando que os elementos sejam apenas alterações visuais de ataques.

## 4.3 Características individuais
Cada dragão deverá possuir:

- Atributos próprios.
- Habilidades elementais.
- Capacidades físicas.
- Capacidade de transporte.
- Características de voo.
- Progressão individual.

## 4.4 Evolução
O sistema de evolução ainda precisa ser especificado.

Aspectos a definir:

- Estágios de crescimento.
- Evolução das habilidades.
- Mudanças de aparência.
- Possíveis especializações.
- Influência da alimentação.
- Influência do vínculo.
- Limites de evolução.

---

# 5. SISTEMA DE ATRIBUTOS

## 5.1 Atributos principais
AtributoSiglaFunçãoVitalidadeHPDetermina a saúde do dragão.Estamina de VooSPEnergia utilizada para voar e executar impulsos.Poder ElementalPEDetermina o dano e a eficiência das habilidades mágicas.Força FísicaFFDetermina o dano de investidas e ataques com garras.CargaCGDetermina o peso máximo transportado.
## 5.2 Atributos complementares
Os testes do Santuário também mencionam características que precisam ser integradas ao sistema:

- Velocidade.
- Agilidade.
- Ataque.
- Crítico.
- Sorte.
Esses atributos ainda não possuem fórmulas ou definições matemáticas estabelecidas.

## 5.3 Estamina de voo
A estamina é consumida por atividades aéreas.

Consumo previsto:

- Bater asas.
- Utilizar impulsos.
- Executar manobras especiais.
- Ativar determinadas habilidades.
Regeneração prevista:

- Planar.
- Pousar.
- Permanecer em repouso.

## 5.4 Capacidade de carga
A capacidade de carga determina o peso máximo de materiais transportados pelo dragão.

Esse atributo será especialmente importante para:

- Mineração.
- Coleta de recursos.
- Transporte de colheitas.
- Exploração de regiões distantes.

---

# 6. SISTEMA DE VÍNCULO

## 6.1 Conceito
O vínculo representa o relacionamento entre o jogador e seu dragão.

A progressão acontece por meio de interações e experiências compartilhadas.

## 6.2 Atividades de fortalecimento

- Alimentar o dragão.
- Cuidar de suas necessidades.
- Voar juntos.
- Explorar novas regiões.
- Participar de combates.
- Realizar treinamentos.

## 6.3 Desbloqueios
O fortalecimento do vínculo deverá permitir o acesso a:

- Novas habilidades de voo.
- Novas habilidades de combate.
- Melhor cooperação.
- Novas possibilidades de interação.
**Decisões pendentes:** definir níveis de vínculo, experiência necessária, recompensas e possíveis efeitos de negligência.

---

# 7. FAZENDA E ADMINISTRAÇÃO

## 7.1 Conceito
A fazenda será a base de operações do jogador.

Ela servirá como local de descanso, produção de recursos, fabricação de itens e preparação para expedições.

## 7.2 Agricultura
O jogador poderá cultivar ingredientes mágicos utilizados na produção de alimentos e outros recursos.

Aspectos a desenvolver:

- Tipos de sementes.
- Tempo de crescimento.
- Condições de cultivo.
- Colheita.
- Qualidade dos ingredientes.
- Sementes raras.

## 7.3 Alimentação dos dragões
Os ingredientes cultivados poderão ser utilizados na preparação de rações especiais.

Esses alimentos terão influência na evolução dos atributos do dragão.

O sistema deverá considerar:

- Ingredientes necessários.
- Receitas.
- Benefícios nutricionais.
- Efeitos temporários ou permanentes.
- Compatibilidade com os elementos.

## 7.4 Construção e instalações
A estrutura de construções da fazenda ainda será definida.

Possíveis categorias:

- Agricultura.
- Armazenamento.
- Cozinha.
- Forja.
- Instalações para os dragões.

---

# 8. SISTEMA DE CRAFTING

## 8.1 Conceito
O crafting permitirá transformar recursos coletados em equipamentos e itens úteis.

## 8.2 Categorias iniciais
**Equipamentos para dragões**

- Selas.
- Armaduras.
- Melhorias de transporte.
**Alimentação**

- Rações comuns.
- Rações especiais.
- Preparações mágicas.
**Materiais**

- Minérios processados.
- Componentes.
- Recursos refinados.

## 8.3 Progressão
A fabricação de itens deverá acompanhar a progressão do jogador e a descoberta de novas regiões.

As receitas, estações de trabalho, materiais e níveis de fabricação serão definidos posteriormente.

---

# 9. EXPLORAÇÃO E MUNDO

## 9.1 Conceito
A exploração será uma das principais atividades do jogador.

O dragão permitirá acessar locais que seriam inacessíveis por meios convencionais.

## 9.2 Ambientes confirmados

- Ilhas flutuantes.
- Cavernas.
- Montanhas.

## 9.3 Elementos de exploração
Durante as expedições, o jogador poderá encontrar:

- Criaturas selvagens.
- Recursos naturais.
- Minérios.
- Sementes raras.
- Materiais especiais.

## 9.4 Progressão de exploração
O acesso a novas áreas poderá depender da evolução do dragão, de suas habilidades de voo e dos equipamentos disponíveis.

A organização dos biomas e a estrutura do mapa ainda serão definidas.

---

# 10. SISTEMA DE COMBATE

## 10.1 Conceito
O combate combinará as ações do jogador com as habilidades do dragão.

O dragão será responsável por ataques físicos, habilidades elementais e ações aéreas.

## 10.2 Combate elemental
Cada arquétipo terá uma identidade de combate:

ElementoEspecialidadeFogoDano elevado e ataques em área.TerraResistência e ataques pesados.VentoMobilidade e ataques ágeis.Água/GeloControle e precisão.
## 10.3 Combate aéreo
O combate aéreo deverá aproveitar as características de voo de cada elemento.

As mecânicas específicas ainda precisam ser definidas.

## 10.4 Inimigos e criaturas
As criaturas selvagens serão fontes de desafios e recursos.

A classificação de inimigos, níveis de dificuldade, chefes e recompensas ainda será desenvolvida.

---

# 11. PROGRESSÃO GERAL
A progressão do jogo deverá conectar o desenvolvimento da propriedade, o fortalecimento do dragão e a exploração.

## 11.1 Progressão do dragão

- Melhoria de atributos.
- Desbloqueio de habilidades.
- Desenvolvimento do vínculo.
- Melhorias de equipamentos.

## 11.2 Progressão da propriedade

- Ampliação da produção.
- Acesso a novas receitas.
- Melhoria das instalações.
- Maior capacidade de armazenamento.

## 11.3 Progressão de exploração

- Descoberta de regiões.
- Acesso a novos recursos.
- Enfrentamento de criaturas mais desafiadoras.
- Descoberta de materiais especiais.
**Observação:** ainda não foi estabelecido um sistema de níveis, experiência ou curva de dificuldade.

---

# 12. DIREÇÃO ARTÍSTICA

## 12.1 Identidade visual
A identidade visual deverá transmitir fantasia medieval e convivência com criaturas fantásticas.

Os principais elementos visuais deverão reforçar:

- A presença dos dragões.
- A atmosfera medieval.
- A natureza fantástica.
- A exploração de ambientes variados.
- A sensação de evolução da propriedade.

## 12.2 Direção dos personagens e criaturas
Os dragões precisam apresentar diferenças visuais coerentes com seus elementos e funções.

A aparência deverá comunicar suas características mesmo antes de o jogador observar seus atributos.

**Definições pendentes:** estilo artístico, paleta de cores, proporções, nível de realismo, animações e referências visuais.

---

# 13. ÁUDIO E TRILHA SONORA
A identidade sonora deverá reforçar a diferença entre os momentos de tranquilidade e aventura.

Categorias a desenvolver:

- Música ambiente da fazenda.
- Música de exploração.
- Música de combate.
- Sons dos dragões.
- Sons ambientais.
- Efeitos das habilidades elementais.
- Sons de agricultura e crafting.

---

# 14. INTERFACE E EXPERIÊNCIA DO USUÁRIO
A interface deverá permitir que o jogador acompanhe suas atividades sem prejudicar a exploração.

Elementos necessários:

- Indicador de HP.
- Indicador de estamina.
- Indicadores de atributos.
- Inventário.
- Equipamentos.
- Informações do dragão.
- Indicador de vínculo.
- Interface de cultivo.
- Interface de crafting.
- Mapa e localização.
A disposição visual, os menus e os controles ainda serão definidos.

---

# 15. DIRETRIZES TÉCNICAS

## 15.1 Engine
Godot 4.3 ou superior.

## 15.2 Perspectiva
Ambiente tridimensional com câmera em terceira pessoa.

## 15.3 Sistemas técnicos necessários
A arquitetura deverá contemplar módulos independentes para:

- Controle do personagem.
- Controle de voo.
- Inteligência artificial do dragão.
- Sistema de atributos.
- Sistema de vínculo.
- Inventário.
- Agricultura.
- Crafting.
- Combate.
- Interação com objetos.
- Gerenciamento do mundo.
- Salvamento e carregamento.

## 15.4 Organização do desenvolvimento
Recomenda-se manter os sistemas desacoplados, permitindo testar e modificar cada mecânica sem comprometer o funcionamento das demais.

A arquitetura definitiva, os padrões de código e a estrutura de pastas serão documentados durante o planejamento técnico.

---

# 16. ESCOPO DE DESENVOLVIMENTO
O desenvolvimento deverá acontecer em etapas para reduzir riscos técnicos.

## Fase 1 — Protótipo de movimentação

- Movimentação em terceira pessoa.
- Câmera.
- Interação básica.
- Primeiro protótipo de voo.

## Fase 2 — Protótipo do dragão

- Modelo inicial.
- Movimentação terrestre.
- Voo.
- Estamina.
- Seguir o jogador.
- Montaria.

## Fase 3 — Ritual do Primeiro Vínculo

- Dilemas de personalidade.
- Pontuação elemental.
- Teste de habilidade.
- Distribuição de atributos.
- Entrega do primeiro dragão.

## Fase 4 — Sistemas de RPG

- Atributos.
- Habilidades.
- Combate.
- Vínculo.
- Progressão.

## Fase 5 — Fazenda e crafting

- Plantio.
- Colheita.
- Inventário.
- Alimentação.
- Fabricação de equipamentos.

## Fase 6 — Exploração

- Biomas.
- Cavernas.
- Montanhas.
- Ilhas flutuantes.
- Criaturas e recursos.

## Fase 7 — Integração e polimento

- Integração dos sistemas.
- Balanceamento.
- Interface.
- Áudio.
- Otimização.
- Testes.

---

# 17. RISCOS E PONTOS DE ATENÇÃO
O projeto reúne diferentes gêneros, o que aumenta sua complexidade.

Os principais riscos identificados são:

**1. Complexidade do voo**
O voo é uma mecânica central e precisa apresentar boa resposta aos controles, câmera estável e movimentação consistente.

**2. Integração dos sistemas**
Fazenda, crafting, exploração e evolução precisam compartilhar recursos e objetivos para evitar sistemas isolados.

**3. Balanceamento elemental**
Os quatro arquétipos precisam oferecer experiências diferentes sem tornar uma escolha claramente superior às demais.

**4. Progressão do dragão**
A evolução precisa ser significativa e perceptível, sem exigir repetição excessiva de atividades.

**5. Escopo**
O desenvolvimento de um mundo 3D com múltiplos sistemas deve ser dividido em protótipos funcionais antes da produção de conteúdo em grande escala.

---

# 18. DECISÕES PENDENTES
As seguintes definições deverão ser tomadas antes de consolidar a versão de produção.

SistemaDecisão necessáriaDragõesEspécies, aparência e variedade.EvoluçãoEstágios de crescimento e ramificações.VínculoNíveis, progressão e recompensas.AtributosFórmulas e limites.PersonalidadeDilemas, pontuação e desempates.Teste práticoDificuldade e distribuição de bônus.FazendaCulturas, instalações e expansão.CraftingReceitas e materiais.MundoBiomas e estrutura do mapa.CombateControles, habilidades e inimigos.ProgressãoExperiência, níveis e dificuldade.NarrativaHistória, personagens e objetivos.ArteEstilo visual e referências.ÁudioIdentidade sonora.PlataformaPC, consoles ou outras plataformas.
---

# 19. VISÃO FINAL DO PRODUTO
Dragons Lair busca proporcionar uma experiência na qual o jogador constrói sua própria jornada ao lado de um dragão.

O Ritual do Primeiro Vínculo estabelece a identidade inicial dessa relação. A fazenda representa o desenvolvimento e a segurança. A exploração permite descobrir o mundo e obter novos recursos. O RPG oferece progressão, especialização e desafios.

O objetivo central é fazer com que o dragão seja parte indispensável da experiência, tanto nos momentos de aventura quanto nas atividades cotidianas.

**Princípio fundamental de design:**

O jogador não deve apenas possuir um dragão. Deve construir uma história com ele.

---

**FIM DO DOCUMENTO — GDD 0.1**

*Documento inicial de referência para o desenvolvimento de Dragons Lair. Todas as mecânicas não especificadas estão sujeitas a definição e aprovação durante as próximas etapas de game design.*