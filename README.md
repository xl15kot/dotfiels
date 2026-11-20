# dotfiels (i3 config)

Конфиги i3wm и связанные компоненты (kitty, rofi, polybar, picom, wallpaper и скрипты разрешения экрана).

> Пакет самого `i3` в команду установки ниже **не включён** (по запросу).

## Зависимости

Используются в конфигах/скриптах:

- `kitty` — терминал (`$mod+Return`)
- `rofi` — лаунчер приложений и переключатель окон
- `polybar` — статус-бар
- `picom` — композитор
- `feh` — установка обоев
- `flameshot` — скриншоты (`Print`)
- `xss-lock`, `i3lock` — блокировка экрана
- `xorg-xrandr` — управление разрешением/мониторами (скрипты i3)
- `xorg-setxkbmap` — раскладка клавиатуры (us/ru, переключение Alt+Shift)
- `libnotify` — уведомления (`notify-send` в скрипте разрешения)
- `nautilus` — файловый менеджер (`$mod+e`)
- `pactl` (из `libpulse`/`pipewire-pulse`) — управление громкостью мультимедиа-клавишами

## Установка (Arch Linux)

```bash
sudo pacman -S --needed kitty rofi polybar picom feh flameshot xss-lock i3lock xorg-xrandr xorg-setxkbmap libnotify nautilus pipewire-pulse
```

> Если используешь PulseAudio вместо PipeWire, замени `pipewire-pulse` на соответствующий пакет, предоставляющий `pactl` (например, `pulseaudio`/`libpulse` в твоей конфигурации).

## Расположение файлов

Репозиторий соответствует содержимому `~/.config/`:

- `i3/` → `~/.config/i3/`
- `kitty/` → `~/.config/kitty/`
- `rofi/` → `~/.config/rofi/`
- `polybar/` → `~/.config/polybar/`
- `picom/` → `~/.config/picom/`
- `wallpaper/` → `~/.config/wallpaper/`
- `resolution.conf` → `~/.config/resolution.conf`

Пример копирования (осторожно, перезапишет существующие файлы):

```bash
cp -r i3 kitty rofi polybar picom wallpaper ~/.config/
cp resolution.conf ~/.config/
```
