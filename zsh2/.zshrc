# vim: set sw=2 ts=2 sts=2 et fmr={{{,}} fdm=marker:
#
# User configuration sourced by interactive shells
# Author: rayjzeng
#

# env and basic options {{{

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

# Misc options
setopt AUTOCD
unsetopt BEEP
unsetopt CORRECT

# }}}

# syntax highlighting {{{

source $ZMODULES/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor)

# }}}

# history {{{

setopt APPENDHISTORY 
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt HIST_BEEP

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"  # History file location
HISTSIZE=10000                             # Internal history size
SAVEHIST=10000                             # History file size

# use history substring search
source $ZMODULES/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

HISTORY_SUBSTRING_SEARCH_FUZZY=on

# }}}

# keybindings and completion {{{

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

# Completion options
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
fpath=("$ZMODULES/zsh-completions" $fpath)

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

# }}}

# prompt {{{

autoload -U promptinit
fpath=($prompt_themes "$ZMODULES/zsh-clean" $fpath)
promptinit
prompt clean 256

# }}}

# user applications {{{

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
source $DOTDIR/dependencies/up/up.sh

# }}}
