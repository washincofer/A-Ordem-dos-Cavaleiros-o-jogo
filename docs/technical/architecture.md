# Arquitetura do Projeto v1

## Convenções
- Godot 4 / GDScript.
- Cenas reutilizáveis em `scenes/`.
- Lógica GDScript em `scripts/`.
- Dados balanceáveis em `data/` ou Resources.
- Arte organizada por personagem/sistema.

## Cenas
- `scenes/core`: bootstrap, estado e roteamento.
- `scenes/player`: player e componentes.
- `scenes/enemies`: inimigos e IA.
- `scenes/world`: mapas, salas, checkpoints e interações.
- `scenes/hub`: base central entre runs.
- `scenes/ui`: HUD, inventário e menus.
- `scenes/vertical_slice`: composição do Vertical Slice v1.

## Scripts
- `scripts/core`: estado global, save e transições.
- `scripts/player`: movimento, combate, stamina e atributos.
- `scripts/enemies`: IA, percepção, estados e arquétipos.
- `scripts/systems`: loot, inventário, run, checkpoint, XP e procedural.
- `scripts/ui`: HUD e menus.

## Regra
Evitar colocar regras canônicas diretamente em cenas quando puderem ser parametrizadas por Resource/dados.
