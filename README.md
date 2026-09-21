# A Ordem dos Cavaleiros — O Jogo

Action RPG 2D/2.5D que combina **Beat 'em up + Metroidvania + Roguelite**, baseado no universo de *A Ordem dos Cavaleiros Breyanos*.

## Stack
- Godot 4
- GDScript
- Git/GitHub
- Export Web para testes/deploy

## Estado atual
Vertical Slice v1 em preparação.

## Estrutura
- `scenes/` — cenas Godot
- `scripts/` — lógica GDScript
- `assets/` — arte, áudio, fontes e FX
- `data/` — dados de personagens, inimigos, itens, loot e progressão
- `resources/` — recursos Godot reutilizáveis
- `docs/` — design e documentação técnica
- `tests/` — cenas e scripts de teste
- `addons/` — plugins Godot


## Teste do Vertical Slice

Ao abrir o projeto no Godot 4.7.2, a cena inicial configurada é:

`res://scenes/vertical_slice/player_sandbox.tscn`

Controles atuais:
- WASD ou setas: movimento
- Shift: corrida
- H: pulo
- Y: ataque principal
- U: chute
- J: defesa
- E: interação
- duplo toque direcional: esquiva

## Deploy no Render

O repositório inclui `render.yaml`, `export_presets.cfg` e `scripts/render_build.sh`.

A configuração publica o jogo como **Render Static Site** após export Web single-threaded do Godot. O primeiro build baixa o Godot 4.7.2 e os templates oficiais; builds seguintes reutilizam o cache do Render quando disponível.

Passos:
1. No Render, escolha **New > Blueprint**.
2. Conecte este repositório.
3. Confirme o `render.yaml` da raiz.
4. Aguarde o build e abra a URL `.onrender.com`.

Mais detalhes: `docs/technical/render_deploy.md`.
