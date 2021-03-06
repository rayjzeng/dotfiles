#
# User configuration sourced by interactive shells
#

# Define zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

if [[ "$(uname -s)" == "Darwin" ]]; then
  export OS="mac"
elif [[ "$(uname -s)" == "Linux" ]]; then
  export OS="linux"
fi

# disable autocorrection
unsetopt correct

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

alias la="ls -A"

alias treed="tree -d"
alias treel="tree -L"

alias zsource="source $HOME/.zshrc"
alias zedit="e $HOME/.zshrc"
alias zeditl="e $HOME/.local-$OS.zsh"

#
# Additional configurations
#

# Local configuration
[[ -e "$HOME/.local-$OS.zsh" ]] && source "$HOME/.local-$OS.zsh"

