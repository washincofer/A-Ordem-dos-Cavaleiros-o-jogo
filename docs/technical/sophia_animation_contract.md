# Sophia — Animation Contract v1

Este documento define os nomes de animação que o código espera encontrar no `AnimatedSprite2D`.

## Aprovadas / disponíveis como referência visual

| Animation name | Frames aprovados | Uso |
| --- | ---: | --- |
| `idle` | 20 | Espera com variações de postura |
| `walk` | 20 | Caminhada |
| `run` | 20 | Corrida |
| `jump` | 20 | Pulo |
| `jump_attack_y` | 20 | H + Y, ataque aéreo com machado |
| `jump_attack_u` | 20 | H + U, chute aéreo |
| `attack_y` | 20 | Cadeia YYYY de machado/adaga |
| `attack_u` | 20 | Cadeia UUUU de chutes |
| `defend` | 20 | Defesa J |
| `dodge` | 20 | Esquiva/rolamento |
| `hurt` | 20 | Dano / reação |
| `stagger` | 20 | Stagger |
| `fall` | 20 | Queda |
| `get_up` | 20 | Levantar |
| `special_executioner_moon` | 20 | Lua do Carrasco |
| `throw_axe` | 20 | Arremesso do machado |
| `throw_dagger` | 10 | Arremesso da adaga |

## Ainda necessários para completar Sophia

- agarrão / segurar inimigo;
- golpe curto no agarrão;
- joelhada;
- arremesso de inimigo para frente;
- arremesso de inimigo para trás;
- stun prolongado;
- morte;
- idle/ataques simplificados sem o machado;
- recuperar machado/adaga do chão;
- interação E.

## Importação

Os concept sheets aprovados são referência visual. Para uso real no Godot, cada animação deve ser exportada como atlas limpo, sem números, títulos, bordas ou fundo opaco, com frames alinhados em células uniformes e transparência real.
