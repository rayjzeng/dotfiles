# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# 
# Additional configuration
#

# Shared configuration
[[ -e ~/.sh_shared ]] && source ~/.sh_shared

# Local configuration
[[ -e ~/.sh_local ]] && source ~/.sh_local

# 
# Utilities
#

if command -v nvim >/dev/null 2>&1; then
  export VISUAL='nvim'
elif command -v vim >/dev/null 2>&1; then
  export VISUAL='vim'
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Base16 color utility
# BASE16_SHELL=$HOME/.config/base16-shell/
# [ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Expand global aliases with <C-Space>
function expand_alias() {
  if [[ $LBUFFER =~ '[A-Za-z0-9_]+$' ]]; then
    zle _expand_alias
    zle expand-word
  fi
  zle magic-space
}

zle -N expand_alias
bindkey "^ " expand_alias 
