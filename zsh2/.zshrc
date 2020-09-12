#
# User configuration sourced by interactive shells
# Author: rayjzeng
#

# Source local configuration if available
[[ -e "${ZDOTDIR:-$HOME}/.zsh_local_env.zsh" ]] && source "${ZDOTDIR:-$HOME}/.zsh_local_env.zsh"

# Add Homebrew to path if configured
if (( ${+BREWDIR} )); then
  typeset -U path
  path=(
    "$BREWDIR/bin"
    "$BREWDIR/sbin"
    $path
  )
  export PATH
fi

# Set up history
setopt appendhistory 
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"  # History file location
HISTSIZE=10000                             # Internal history size
SAVEHIST=10000                             # History file size

# Misc options
setopt autocd
setopt beep
unsetopt correct

# Use zsh-clean theme
autoload -U promptinit
fpath=($prompt_themes "$DOTDIR/zsh2/zsh-clean" $fpath)
promptinit
prompt clean 256

#
# Keybindings
#

# use emacs bindings
bindkey -e

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
# Completion
#

setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
setopt AUTO_MENU           # Show completion menu on a successive tab press.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash.
setopt EXTENDED_GLOB       # Needed for file modification glob modifiers with compinit
unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.

# Use caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# Load completions from zsh-completions
if whence brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh-completions" $fpath)
fi

# Regenerate cache every day or so
# Explanation of glob:
# - 'N' makes glob evaluate to nothing when it doesn't match
# - '.' matches plain files
# - 'mh-23' matches files/directories that were modified within the last 23 hrs
autoload -Uz compinit
_comp_files=(${ZDORDIR:-$HOME}/.zcompdump(N.mh-23))
if (( $#_comp_files )); then
  compinit -C;
else
  compinit -d "${ZDOTDIR:-$HOME}/.zcompdump";
fi
unset _comp_files

#
# User applications
#

# Default editors
if whence nvim &>/dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
elif whence vim &>/dev/null; then
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
