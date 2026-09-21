# Deploy no Render — Vertical Slice v1

## Arquitetura

O jogo é exportado pelo Godot como **Web single-threaded** e publicado como **Render Static Site**.

Essa escolha evita a necessidade de um servidor de aplicação e também evita a exigência de COOP/COEP do export Web com threads.

## Versão fixada

- Godot: **4.7.2-stable**
- Export preset: `Web`
- Render publish path: `build/web`

## Arquivos

- `export_presets.cfg`: preset Web.
- `scripts/render_build.sh`: baixa/cacheia o Godot e os templates oficiais, importa o projeto, exporta e descompacta o jogo.
- `render.yaml`: Blueprint do Render.

## Primeiro deploy

1. Fazer merge do PR do Vertical Slice para `main`.
2. No Render: **New > Blueprint**.
3. Selecionar o repositório `washincofer/A-Ordem-dos-Cavaleiros-o-jogo`.
4. Usar o `render.yaml` da raiz.
5. Confirmar a criação do Static Site.

O primeiro build é o mais demorado porque baixa o pacote oficial de export templates do Godot. O script usa `$XDG_CACHE_HOME`, que o Render preserva entre builds, para evitar downloads repetidos sempre que o cache continuar disponível.

## Atualizações

O Blueprint está configurado com `autoDeployTrigger: commit`. Depois da criação do site, novos commits na `main` disparam novos builds automaticamente.

## Saída esperada

Após o build:
- `build/web/index.html`
- JavaScript gerado pelo Godot
- WebAssembly
- pacote do projeto e demais arquivos do export

## Diagnóstico

Se o deploy falhar, olhar o log do Build no Render. O script para imediatamente em caso de:
- falha no download do Godot;
- template Web ausente;
- erro de importação/exportação;
- ausência de `build/web/index.html`.

Para problemas em execução no navegador, abrir o console do navegador com F12 e verificar erros de JavaScript/WebGL.
