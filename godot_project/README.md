# Dragons Lair — Protótipo Godot

Projeto inicial jogável para Godot 4.3 ou superior. A renderização usa **Compatibility (OpenGL)** para ampliar a compatibilidade com computadores modestos. O cenário e os personagens são placeholders 3D construídos com meshes nativas, sem dependências externas.

## Executar

1. Abra `godot_project/project.godot` no Godot.
2. Aguarde a importação inicial e pressione **F5** para iniciar o Ritual do Primeiro Vínculo.
3. Conclua as três provas, escolha os nomes e salve o pergaminho para iniciar a fazenda. Na fazenda, a exploração a pé usa câmera em primeira pessoa e captura o mouse ao iniciar; pressione **Esc** para liberá-lo ou recapturá-lo. Ao montar, a câmera alterna para acompanhamento em terceira pessoa.

## Controles

| Tecla | Ação |
|---|---|
| W, A, S, D | Mover o personagem ou conduzir o dragão |
| Shift | Correr a pé ou impulsionar durante o voo |
| Espaço | Pular a pé; decolar e executar impulso de batida no ar |
| C | Inclinar para baixo durante o voo |
| Mouse | Girar a câmera; olhar para cima/baixo controla a subida e o mergulho montado |
| E | Interagir com recursos, porta e canteiros |
| F | Montar ou desmontar (é necessário pousar para desmontar) |
| G | Alternar entre seguir e ficar parado |
| S | Freio aerodinâmico enquanto voa |
| J ou clique esquerdo | Atacar durante a Prova de Aço e Magia |
| Esc | Liberar/recapturar o mouse |

## Sistemas implementados

- Prólogo jogável em três fases: teste de personalidade, circuito de parkour e combate.
- Ritual Padrão (30 perguntas) e Ritual Completo (60 afirmações Likert); afinidade complementar MBTI em cinco eixos.
- Catálogo de 16 espécies baseadas no MBTI complementar do dragão; a rota determina o elemento e os bônus, com limite de 3 minutos e estado Exausto ao esgotar o tempo.
- Escolha permanente entre oito armas e batalha sem Game Over; vitória define Audacioso ou Protetor, derrota define Medroso.
- Pergaminho de Vínculo com nome e dados salvos em `user://dragon_data.tres`, carregados pelo protótipo da fazenda.
- Testes automatizados do questionário, recursos, fases e geração dos dados podem ser executados com `godot --path godot_project --script res://tests/ritual_smoke_test.gd`.

- Personagem humanoide provisório, caminhada, corrida, gravidade, colisão e pulo.
- Câmera em primeira pessoa a pé, com movimento relativo ao olhar; na montaria, câmera de acompanhamento com SpringArm3D e colisão.
- Voo montado com momentum, mergulho e carga cinética, zoom climb, estol, impulso de batida, freio aerodinâmico, bancagem e feedback dinâmico de câmera.
- Dragão provisório com silhueta composta, comportamento de seguir/parar e voo de acompanhamento.
- Montaria terrestre e aérea, decolagem, subida, descida, planar, pouso e regeneração/consumo de estamina.
- Recurso `DragonStats` para os atributos iniciais do dragão.
- HUD com HP, estamina, nome, elemento, estado, velocidade durante a montaria e recursos coletados.
- Interação com recursos demonstrativos, porta da casa e canteiros.
- Cenário de fazenda com casa, plantação, cercas, árvores, rochas, caminho e elevação.

## Estrutura

- `scenes/`: cenas principal, jogador, dragão, cenário e HUD.
- `src/`: controladores e sistemas separados por responsabilidade.
- `resources/dragons/`: dados iniciais do dragão.
- `src/resources/dragon_data.gd`: ficha persistente gerada pelo ritual.
- `assets/`: reservado para recursos visuais e sonoros futuros.

## Limites conhecidos

- Os modelos e materiais são placeholders; não há animações esqueléticas nem assets de produção.
- O voo é arcade; combate aéreo e dano ao dragão ainda não estão implementados.
- O inventário, a produção da fazenda e o progresso da jornada não são persistidos; o salvamento atual cobre somente a ficha criada pelo ritual.
- A interação com agricultura é demonstrativa; crescimento, receitas e crafting ainda não estão implementados.
- A navegação do companheiro é simples e não usa NavigationServer para contornar obstáculos complexos.
- A personalidade e os traços são persistidos como dados para sistemas futuros; reações de IA/NPC, animações exclusivas e redenção completa ainda não estão conectadas ao gameplay.
