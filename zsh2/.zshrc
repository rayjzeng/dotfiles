#
# User configuration sourced by interactive shells
#

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd

unsetopt beep

bindkey -e

unsetopt correct

#
# User applications
#

export PATH="$HOME/homebrew/bin:$HOME/homebrew/sbin:$PATH"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

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
# Additional settings
#

[[ -e "$HOME/.local-zsh-config.zsh" ]] && source "$HOME/.local-zsh-config.zsh"
