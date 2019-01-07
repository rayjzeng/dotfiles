#
# User configuration sourced by interactive shells
#

# Define zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh


# disable autocorrection
unsetopt correct

#
# Environment setup
#

export DOT_DIR=$HOME/dotfiles

# OPAM for OCaml
. $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# Rust path
export PATH="$HOME/.cargo/bin:$PATH"
if command -v rustc >/dev/null 2>&1; then
  RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src";
fi

# miniconda3
export PATH="$HOME/miniconda3/bin:$PATH"

# iterm2 integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

#
# Utilities
#

# Default editors
if command -v nvim >/dev/null 2>&1; then
  export EDITOR='nvim'
  export VISUAL='nvim'
elif command -v vim >/dev/null 2>&1; then
  export EDITOR='vim'
  export VISUAL='vim'
fi
alias e="$EDITOR"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd -I -H -E ".git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Up
source $DOT_DIR/dependencies/up/up.sh

# Expand aliases with <C-Space>
function expand_alias() {
  if [[ $LBUFFER =~ '[A-Za-z0-9_]+$' ]]; then
    zle _expand_alias
    zle expand-word
  fi
  zle magic-space
}

zle -N expand_alias
bindkey "^ " expand_alias

# 
# Aliases
#

alias la="ls -A"

alias treed="tree -d"
alias treel="tree -L"

#
# Additional configurations
#

# Local configuration
[[ -e ~/.local.sh ]] && source ~/.local.sh

