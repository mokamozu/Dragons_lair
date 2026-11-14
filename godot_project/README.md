# Dragons Lair — Protótipo Godot

Projeto inicial jogável para Godot 4.3 ou superior. A renderização usa **Compatibility (OpenGL)** para ampliar a compatibilidade com computadores modestos. O cenário e os personagens são placeholders 3D construídos com meshes nativas, sem dependências externas.

## Executar

1. Abra `godot_project/project.godot` no Godot.
2. Aguarde a importação inicial e pressione **F6** ou **F5** para iniciar a cena principal.
3. Na primeira execução, clique na janela do jogo para capturar o mouse. Pressione **Esc** para liberar ou recapturar o mouse.

## Controles

| Tecla | Ação |
|---|---|
| W, A, S, D | Mover o personagem ou conduzir o dragão |
| Shift | Correr a pé ou impulsionar durante o voo |
| Espaço | Pular a pé; decolar/subir montado |
| C | Descer durante o voo |
| Mouse | Girar a câmera |
| E | Interagir com recursos, porta e canteiros |
| F | Montar ou desmontar (é necessário pousar para desmontar) |
| G | Alternar entre seguir e ficar parado |
| Esc | Liberar/recapturar o mouse |

## Sistemas implementados

- Personagem humanoide provisório, caminhada, corrida, gravidade, colisão e pulo.
- Câmera de terceira pessoa com SpringArm3D, rotação por mouse e colisão.
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
- `assets/`: reservado para recursos visuais e sonoros futuros.

## Limites conhecidos

- Os modelos e materiais são placeholders; não há animações esqueléticas nem assets de produção.
- O voo é arcade e não inclui combate, dano, inventário persistente ou salvamento.
- A interação com agricultura é demonstrativa; crescimento, receitas e crafting ainda não estão implementados.
- A navegação do companheiro é simples e não usa NavigationServer para contornar obstáculos complexos.
