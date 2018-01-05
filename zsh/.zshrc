# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Hide user@hostname
DEFAULT_USER=`whoami`
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# Shared configuration
[[ -e ~/.sh_shared ]] && source ~/.sh_shared
# Local configuration
[[ -e ~/.sh_local ]] && source ~/.sh_local

# User programs ###############################################

# Base16 color utility
# BASE16_SHELL=$HOME/.config/base16-shell/
# [ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# OPAM for OCaml
. $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# Rust path
export PATH="$HOME/.cargo/bin:$PATH"
if command -v rustc > /dev/null 2>&1; then
  RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src";
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
