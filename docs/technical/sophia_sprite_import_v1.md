# Sophia Sprite Import v1

O Player Sandbox já possui carregamento automático dos primeiros atlas técnicos da Sophia.

## Arquivos esperados

Copiar exatamente para:

```
assets/art/characters/sophia/sprites/atlases/sophia_idle_20f.png
assets/art/characters/sophia/sprites/atlases/sophia_walk_20f.png
```

## Formato

- 20 frames por animação.
- Grade: 5 colunas x 4 linhas.
- Cada célula: 192x192 px.
- PNG com transparência.
- Idle: 10 FPS.
- Walk: 14 FPS.

## Funcionamento

`SophiaSpriteLoader` constrói o `SpriteFrames` em runtime.

Se os PNGs existirem:
- o placeholder é ocultado;
- Sophia usa os sprites aprovados;
- `idle` e `walk` são ativados automaticamente pelo controller.

Se não existirem:
- o projeto continua executando;
- um placeholder aparece para permitir testes de lógica sem quebrar a cena.

## Próximas animações

As próximas animações serão adicionadas ao mesmo loader:
`run`, `jump`, `jump_attack_y`, `jump_attack_u`, `attack_y`, `attack_u`, `defend`, `dodge`, `hurt`, `stagger`, `fall`, `get_up`, `special_executioner_moon`, `throw_axe` e `throw_dagger`.
