# vim: set sw=2 ts=2 sts=2 et fdm=marker:
#
# User configuration sourced by interactive shells
# Author: rayjzeng
#

# env and basic options {{{

# Source local configuration if available
[[ -f "${ZDOTDIR:-$HOME}/.zshenv_local.zsh" ]] && source "${ZDOTDIR:-$HOME}/.zshenv_local.zsh"

# set default environments if needed
[[ -v ZDOTDIR ]] || ZDOTDIR=$HOME
[[ -v DOTDIR ]] || DOTDIR=$HOME/dotfiles

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

# }}}

# editor {{{

unsetopt BEEP
unsetopt CORRECT

# directory stack
DIRSTACKSIZE=10
setopt AUTOCD
setopt AUTOPUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHDMINUS
setopt PUSHDSILENT
setopt PUSHDTOHOME

# FZF
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_COMMAND='fd -H -E "{**/.git,**/.hg,**/.svn}"'
export FZF_CTRL_T_COMMAND='fd -I -H -E "{**/.git,**/.hg,**/.svn}"'

# z.lua
zlua_path="$ZMODULES/z.lua/z.lua"
if [[ -f "$zlua_path" ]]; then
  eval "$(lua ${zlua_path} --init zsh)"

  export _ZL_MATCH_MODE=1  # use enhanced matching so z acts like cd for unvisited directories

  alias zb="z -b"
  alias zf="z -I"
  alias zbf="z -b -I"
fi
unset zlua_path

# Use human-friendly identifiers.
zmodload -F zsh/terminfo +b:echoti +p:terminfo
typeset -gA key_info
key_info=(
  'Control'      '\C-'
  'ControlLeft'  '\e[1;5D \e[5D \e\e[D \eOd \eOD'
  'ControlRight' '\e[1;5C \e[5C \e\e[C \eOc \eOC'
  'Escape'       '\e'
  'Meta'         '\M-'
  'Backspace'    "${terminfo[kbs]}"
  'BackTab'      "${terminfo[kcbt]}"
  'Left'         "${terminfo[kcub1]}"
  'Down'         "${terminfo[kcud1]}"
  'Right'        "${terminfo[kcuf1]}"
  'Up'           "${terminfo[kcuu1]}"
  'Delete'       "${terminfo[kdch1]}"
  'End'          "${terminfo[kend]}"
  'F1'           "${terminfo[kf1]}"
  'F2'           "${terminfo[kf2]}"
  'F3'           "${terminfo[kf3]}"
  'F4'           "${terminfo[kf4]}"
  'F5'           "${terminfo[kf5]}"
  'F6'           "${terminfo[kf6]}"
  'F7'           "${terminfo[kf7]}"
  'F8'           "${terminfo[kf8]}"
  'F9'           "${terminfo[kf9]}"
  'F10'          "${terminfo[kf10]}"
  'F11'          "${terminfo[kf11]}"
  'F12'          "${terminfo[kf12]}"
  'Home'         "${terminfo[khome]}"
  'Insert'       "${terminfo[kich1]}"
  'PageDown'     "${terminfo[knp]}"
  'PageUp'       "${terminfo[kpp]}"
)

# use emacs bindings
bindkey -e

# Bind <Shift-Tab> to go to the previous menu item.
if [[ -n ${key_info[BackTab]} ]] bindkey ${key_info[BackTab]} reverse-menu-complete

# fix some keys
if [[ -n ${key_info[Home]} ]] bindkey ${key_info[Home]} beginning-of-line
if [[ -n ${key_info[End]} ]] bindkey ${key_info[End]} end-of-line
if [[ -n ${key_info[PageUp]} ]] bindkey ${key_info[PageUp]} up-line-or-history
if [[ -n ${key_info[PageDown]} ]] bindkey ${key_info[PageDown]} down-line-or-history
if [[ -n ${key_info[Insert]} ]] bindkey ${key_info[Insert]} overwrite-mode
if [[ -n ${key_info[Delete]} ]] bindkey ${key_info[Delete]} delete-char

# }}}

# syntax highlighting {{{

z_syntax_path=$ZMODULES/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f "$z_syntax_path" ]] && source $z_syntax_path
unset z_syntax_path

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

HISTFILE="$ZDOTDIR/.zsh_history"  # History file location
HISTSIZE=10000                             # Internal history size
SAVEHIST=10000                             # History file size

# use history substring search
z_hist_search=$ZMODULES/zsh-history-substring-search/zsh-history-substring-search.zsh
if [[ -f "$z_hist_search" ]]; then
  source $z_hist_search

  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down

  HISTORY_SUBSTRING_SEARCH_FUZZY=on
fi
unset z_hist_search

# }}}

# completion {{{

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
zstyle ':completion::complete:*' cache-path "$ZDOTDIR/.zcompcache"

# Load completions from zsh-completions
[[ -d "$ZMODULES/zsh-completions" ]] && fpath=("$ZMODULES/zsh-completions" $fpath)

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
  compinit -d "$ZDOTDIR/.zcompdump";
fi
unset _comp_files

# }}}

# prompt {{{

if [[ -d "$ZMODULES/zsh-clean" ]]; then
  autoload -U promptinit
  fpath=($prompt_themes "$ZMODULES/zsh-clean" $fpath)
  promptinit
  prompt clean 256
fi

# }}}

# additional aliases {{{

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

# Default editors
if whence nvim &>/dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
elif whence vim &>/dev/null; then
  export EDITOR='vim'
  export VISUAL='vim'
fi
alias e="$EDITOR"

# python venv
function activate() {
  if [ $# -ne 1 ]; then
    echo "Usage: activate [virtual env directory]"
  else
    source "$1/bin/activate"
  fi
}

# iterm2 integration
[[ -e "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# }}}
