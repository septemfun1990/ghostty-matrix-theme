---
name: ghostty-matrix-theme-installer
description: Install and validate the Ghostty Matrix Theme on macOS. Use when an agent needs to copy this repo's Ghostty config and shaders into the standard Ghostty config directory, verify fonts, and explain restart requirements.
---

# Ghostty Matrix Theme Installer

Use this skill when the task is to install or update this repository's Ghostty theme on macOS.

## What to install

- `config`
- `shaders/matrix_display.glsl`
- `shaders/matrix_cursor_halo.glsl`

Target location:

- `~/Library/Application Support/com.mitchellh.ghostty/config`
- `~/Library/Application Support/com.mitchellh.ghostty/shaders/`

## Install workflow

1. Confirm the repository root contains `config` and `shaders/`.
2. Run `./install.sh --dry-run` first when you want to preview the target paths.
3. Run `./install.sh` from the repository root.
4. Note that the installer backs up any existing managed Ghostty files before overwriting them.
5. Validate the installed config with:

```bash
'/Applications/Ghostty.app/Contents/MacOS/ghostty' +validate-config
```

6. Tell the user to fully quit and reopen Ghostty.

## Fonts

Preferred fonts:

- `JetBrains Mono`
- `Sarasa Mono TC`

If they are missing, suggest:

```bash
brew install --cask font-jetbrains-mono font-sarasa-gothic
```

## Notes

- This theme uses custom shaders, so copy both shader files.
- This repository is sufficient for moving the theme itself, but not for bundling the font binaries.
- `background-opacity` and some macOS window settings are most reliable after a full restart.
- If the user's prompt depends on Nerd Font icons, recommend switching the primary font to a Nerd Font variant after installation.
