# vim: set sw=2 ts=2 sts=2 et fdm=marker:
#
# User configuration sourced by interactive shells
# Author: rayjzeng
#

# set default environments if needed
(( ${+DOTDIR} ))    || DOTDIR=$HOME/dotfiles
(( ${+ZDOTDIR} ))   || ZDOTDIR=$HOME
(( ${+ZMODULES} ))  || ZMODULES=$ZDOTDIR/.zmodules

# source pre init
[[ -f "$ZDOTDIR/.zshrc.before.zsh" ]] && source "$ZDOTDIR/.zshrc.before.zsh"

# env {{{

if [[ -n "$SSH_TTY" || -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$IS_REMOTE" ]]; then
  export IS_REMOTE=1
fi

# Signal WezTerm the pane's remote state on every prompt. Emitting from precmd
# (not just at startup) is what lets WezTerm revert the scheme promptly when you
# return to a local prompt after exiting ssh — its update-status event doesn't
# fire reliably while a pane sits idle. Values are base64: MQ=="1", MA=="0".
function _wezterm_signal_remote {
  if [[ -n "$IS_REMOTE" ]]; then
    printf '\033]1337;SetUserVar=IS_REMOTE=MQ==\007'
  else
    printf '\033]1337;SetUserVar=IS_REMOTE=MA==\007'
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _wezterm_signal_remote

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

path=(
  "$HOME/.local/bin"
  $path
  "/Applications/WezTerm.app/Contents/MacOS"
)

setopt LONG_LIST_JOBS     # List jobs in the long format by default.
setopt NOTIFY             # Report status of background jobs immediately.
unsetopt BG_NICE          # Don't run all background jobs at a lower priority.

# }}}

# editor {{{

unsetopt BEEP
unsetopt CORRECT

WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# directory stack
DIRSTACKSIZE=10
setopt AUTOCD
setopt AUTOPUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHDMINUS
setopt PUSHDSILENT
setopt PUSHDTOHOME

# keybinding configuration
bindkey -e

autoload -Uz zkbd
if [[ -f "$HOME/.zkbd/$TERM-${DISPLAY:-$VENDOR-$OSTYPE}" ]]; then
  source "$HOME/.zkbd/$TERM-${DISPLAY:-$VENDOR-$OSTYPE}"
else
  echo "WARNING: Keybindings may not be set correctly!"
  echo "Execute \`zkbd\` to create bindings."
fi

zmodload zsh/terminfo

# Bind <Shift-Tab> to go to the previous menu item.
if [[ -n ${terminfo[kcbt]} ]] bindkey ${terminfo[kcbt]} reverse-menu-complete

# fix some keys
if [[ -n ${key[Home]} ]] bindkey ${key[Home]} beginning-of-line
if [[ -n ${key[End]} ]] bindkey ${key[End]} end-of-line
if [[ -n ${key[PageUp]} ]] bindkey ${key[PageUp]} up-line-or-history
if [[ -n ${key[PageDown]} ]] bindkey ${key[PageDown]} down-line-or-history
if [[ -n ${key[Insert]} ]] bindkey ${key[Insert]} overwrite-mode
if [[ -n ${key[Delete]} ]] bindkey ${key[Delete]} delete-char

# iTerm2 opt+arrow key binds
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3A' history-substring-search-up
bindkey '^[[1;3B' history-substring-search-down

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

HISTFILE="$ZDOTDIR/.zsh_history"    # History file location
HISTSIZE=1000000                    # Internal history size
SAVEHIST=1000000                    # History file size

# use history substring search
z_hist_search=$ZMODULES/zsh-history-substring-search/zsh-history-substring-search.zsh
if [[ -f "$z_hist_search" ]]; then
  source $z_hist_search

  if [[ -n ${key[Up]} ]] bindkey ${key[Up]} history-substring-search-up
  if [[ -n ${key[Down]} ]] bindkey ${key[Down]} history-substring-search-down
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
unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.

# Use caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$ZDOTDIR/.zcompcache"

# Load completions from zsh-completions
_module="$ZMODULES/zsh-completions"
[[ -d $_module ]] && fpath=($_module $fpath)

# Load more completions
_module="$ZMODULES/third-party"
if [[ -d $_module ]]; then
  zstyle ':completion:*:*:git:*' script "$_module/git-completion.bash"
  fpath=($_module $fpath)
fi
unset _module

# options
# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|?=**'

setopt EXTENDED_GLOB       # Needed for file modification glob modifiers with compinit

# Regenerate cache every day or so
# Explanation of glob in _comp_files:
# - 'N' makes glob evaluate to nothing when it doesn't match
# - '.' matches plain files
# - 'mh-23' matches files/directories that were modified within the last 23 hrs
# $# evaluates to the length of the parameter
autoload -Uz compinit bashcompinit
_comp_files=(${ZDORDIR:-$HOME}/.zcompdump(N.mh-23))
if (( $#_comp_files )); then
  compinit -C;
else
  compinit -d "$ZDOTDIR/.zcompdump";
fi
unset _comp_files

bashcompinit

unsetopt EXTENDED_GLOB

# }}}

# prompt {{{

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# }}}

# additional aliases and utilities {{{

# Default editors
if whence vim &>/dev/null; then
  export EDITOR='vim'
  export VISUAL='vim'
fi
alias e="$EDITOR"

# FZF
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi
if whence fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd -H -E "{**/.git,**/.hg,**/.svn}"'
  export FZF_CTRL_T_COMMAND='fd -I -H -E "{**/.git,**/.hg,**/.svn}"'
fi

# zoxide (fast directory jumper)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias zf="zi"
fi

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

# ls colors
alias ls='ls --color=auto'

if [[ "$VENDOR-$OSTYPE" = apple-darwin* ]]; then  # override on mac
  if whence gls &>/dev/null; then
    alias ls='gls --color=auto'
  else
    alias ls='ls -G'
  fi
  export GREP_COLOR='1;97;45'  # mac uses BSD grep
else
fi

alias l='ls -A'
alias ll='ls -lh'
alias la='ll -A'

alias mkdir='mkdir -p'

# grep colors
export GREP_COLORS='mt=$1;97;45:sl=:cx=:fn=35:ln=32:bn=32:se=36'     # GNU.
alias grep='grep --color=auto'

# less options and styling defaults
export LESS='-F -i -M -R -S -z-2 -q'
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;35m'
export LESS_TERMCAP_me=$'\e(B\e[m'
export LESS_TERMCAP_so=$'\e[1;30;107m'
export LESS_TERMCAP_se=$'\e[27m\e(B\e[m'
export LESS_TERMCAP_us=$'\e[4;1;36m'
export LESS_TERMCAP_ue=$'\e[24m\e(B\e[m'
export LESS_TERMCAP_mr=$'\e[7m'
export LESS_TERMCAP_mh=$'\e[2m'
export LESS_TERMCAP_ZN=$'\e[s'
export LESS_TERMCAP_ZV=$'\e[u'
export LESS_TERMCAP_ZO=$'\e[s'
export LESS_TERMCAP_ZW=$'\e[u'
export GROFF_NO_SGR=1

alias g=git
alias cl=claude
cls() { claude --dangerously-skip-permissions; }

# python venv
function activate() {
  if [ $# -ne 1 ]; then
    echo 'Usage: activate [virtual env directory]'
  else
    source "$1/bin/activate"
  fi
}

# lazy-load NVM — defers ~800ms of startup cost until first use
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  nvm()  { unset -f nvm node npm npx; \. "$NVM_DIR/nvm.sh"; nvm "$@"; }
  node() { unset -f nvm node npm npx; \. "$NVM_DIR/nvm.sh"; node "$@"; }
  npm()  { unset -f nvm node npm npx; \. "$NVM_DIR/nvm.sh"; npm "$@"; }
  npx()  { unset -f nvm node npm npx; \. "$NVM_DIR/nvm.sh"; npx "$@"; }
fi

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/rayzeng/.opam/opam-init/init.zsh' ]] || source '/Users/rayzeng/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

# WezTerm shell integration (scroll-to-prompt, CWD tracking, semantic zones)
[[ -f "$HOME/.config/wezterm/wezterm.sh" ]] && source "$HOME/.config/wezterm/wezterm.sh"

# }}}

# syntax highlighting {{{

z_syntax_path=$ZMODULES/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f "$z_syntax_path" ]] && source $z_syntax_path
unset z_syntax_path

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor)

# }}}

# source post init
[[ -f "$ZDOTDIR/.zshrc.after.zsh" ]] && source "$ZDOTDIR/.zshrc.after.zsh"
