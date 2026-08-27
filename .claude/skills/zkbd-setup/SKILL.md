---
name: zkbd-setup
description: Generate or refresh zsh zkbd key bindings for the current terminal and copy them to tmux-256color and screen-256color variants. Use after terminal, OS, or tmux changes, or when zsh reports missing bindings.
---

# zkbd Setup

Generate bindings in the host terminal, preferably outside tmux, then install
equivalent files for the terminal names used by multiplexers.

## Workflow

1. Confirm `zsh` is installed. If the user's login shell is not zsh, mention
   that the bindings apply only when zsh runs; do not change the login shell
   without permission.
2. From the dotfiles repository, stow the zsh package if needed:

   ```sh
   stow zsh
   ```

3. Run the installed helper from the terminal whose key sequences should be
   captured:

   ```sh
   zkbd-setup
   ```

   The script launches `zkbd`, keeps the generated
   `~/.zkbd/$TERM-${DISPLAY:-$VENDOR-$OSTYPE}` file, and copies it to matching
   `tmux-256color` and `screen-256color` filenames. This covers the repository's
   `screen-256color` tmux configuration as well as machines using
   `tmux-256color`.

4. Start a new zsh session and confirm the missing-bindings warning is gone.

The script accepts an existing bindings file as its only argument when the user
wants to copy known-good bindings without rerunning the interactive `zkbd`
prompt.
