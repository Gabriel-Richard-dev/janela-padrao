# janela-padrao

Põe qualquer janela num tamanho e posição "padrão": grande, centralizada e com margem, como um navegador
semi-maximizado. Funciona com um atalho, sem extensões do GNOME e sem nada rodando em segundo plano
(além do `xbindkeys`, só para o atalho do mouse).

Dois jeitos de usar:

| Ação | O que faz |
|---|---|
| **Super + Shift + B** | Coloca a **janela em foco** no padrão |
| **Super + Shift + duplo clique** | Coloca a **janela sob o cursor** no padrão |

Se a janela estiver maximizada ou em tela cheia, ela é restaurada antes.

## Requisitos

- Sessão **X11** (no Ubuntu: "Ubuntu on Xorg"). **Não funciona no Wayland**, porque usa `wmctrl` e `xdotool`.
- `xdotool`, `wmctrl`, `xprop`, `xrandr`, `xbindkeys`
- O atalho de teclado é criado automaticamente no **GNOME**. Em outros ambientes, crie você mesmo um atalho
  para `~/.local/bin/janela-padrao` (o duplo clique funciona em qualquer ambiente X11).

## Instalar

```bash
# Debian/Ubuntu
sudo apt install xdotool wmctrl x11-utils x11-xserver-utils xbindkeys

git clone https://github.com/Gabriel-Richard-dev/janela-padrao.git
cd janela-padrao
./install.sh
```

O instalador não usa `sudo`. Ele copia dois scripts para `~/.local/bin`, cria o atalho Super+Shift+B (GNOME),
adiciona um bloco ao `~/.xbindkeysrc` (sem mexer no que você já tem) e inicia o `xbindkeys`.

## Desinstalar

```bash
./uninstall.sh
```

## Configurar

Por padrão a janela ocupa 97% da largura e 89% da altura do monitor onde ela está, centralizada, a 51 px do
topo. Para mudar, crie `~/.config/janela-padrao/config`:

```bash
WIDTH_PCT=90      # largura, em % do monitor
HEIGHT_PCT=85     # altura, em % do monitor
TOP=60            # distância do topo, em px (para passar da barra superior)
```

Ou use uma área fixa em pixels (x, y, largura, altura da parte visível, em coordenadas da tela toda):

```bash
FIXED_GEOMETRY="1050,51,1855,962"
```

Para ver a área calculada sem mexer em nenhuma janela:

```bash
JANELA_PADRAO_DRY=1 janela-padrao
```

## Como funciona

- Calcula a área a partir do monitor (`xrandr`) em que está o centro da janela, então funciona com vários monitores.
- Descobre a sombra de cada janela (`_GTK_FRAME_EXTENTS`) e compensa, para a parte **visível** ficar do mesmo tamanho
  em apps com sombra grande (GNOME) e pequena.
- O duplo clique é detectado pelo próprio script: o `xbindkeys` o chama a cada Super+Shift+clique, e ele só age
  no segundo clique dentro de 0,5 s.

## Limitações

- Super + Shift + clique é capturado pelo `xbindkeys`, então esse clique não chega ao app.
- Se você usa `~/.xbindkeysrc.scm` (Guile), ele tem prioridade sobre `~/.xbindkeysrc`; o instalador avisa e mostra a
  linha equivalente.
- Só age quando você pede. Não posiciona janelas novas automaticamente.

## Licença

MIT
