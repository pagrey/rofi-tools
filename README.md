# Rofi Utility Scripts
These scprits provide extra features that you can add to rofi.

These scripts are implemented in rofi mode, not as a stand-alone executable that launches rofi.  This makes it possible to combine the script with rofi and use modi. For instance, you can have multiple modi available (`-modi`) or combine multiple modi in one mode (`-combi-modi`), pass your own themes (`-theme`) and configurations as CLI flags (e.g., `-fullscreen`, `-sidebar-mode`, `-matching fuzzy`, `-location`).

## Scripts

* Basic Power Manager
* Backlight Control
* Internet Radio using ffplay
* Volume using alsa/amixer
* Network Manager using iwd/iproute2

## Install

You can use the script directly from their directory without needing to install it at all. If you want rofi to find it more easily, the script needs to be found in `PATH`.

## Usage

A simple example showing how to launch the power menu:

```
rofi -show "w" -modes "w:rofi-power.sh"
```
If you didn't install the script in `PATH`, you need to give the path to the
script. If you're running rofi in the directory where the script is, you can
run it as follows:

```
rofi -show "w" -modes "w:./rofi-power.sh"
```
