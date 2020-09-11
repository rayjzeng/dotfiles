#
# User configuration sourced by interactive shells
#

# Source local configuration if available
[[ -e "${ZDOTDIR:-$HOME}/.zsh_local_env.zsh" ]] && source "${ZDOTDIR:-$HOME}/.zsh_local_env.zsh"

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory 

setopt autocd
unsetopt beep
unsetopt correct

# Add Homebrew to path
if (( ${+BREWDIR} )); then
  typeset -U path
  path=(
    "$HOME/homebrew/bin"
    "$HOME/homebrew/sbin"
    $path
  )
  export PATH
fi

# Theme
autoload -U promptinit
fpath=($prompt_themes "$DOTDIR/zsh2/zsh-clean" $fpath)
promptinit
prompt clean 256

#
# Keybindings
#

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

bindkey -e

# Completion
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh-completions" $fpath)
  autoload -Uz compinit
  compinit
fi

#
# User applications
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
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_COMMAND='fd -H -E "{**/.git,**/.hg,**/.svn}"'
export FZF_CTRL_T_COMMAND='fd -I -H -E "{**/.git,**/.hg,**/.svn}"'

# Up
source $HOME/dotfiles/dependencies/up/up.sh
