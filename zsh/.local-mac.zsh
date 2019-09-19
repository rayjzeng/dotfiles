
#
# Classwork
#

function activate() {
  if [ $# -ne 1 ]; then
    echo "Usage: activate [virtual env directory]"
  else
    source "$1/bin/activate"
  fi
}


#
# Geomesa
#

export GEOSERVER_HOME="$HOME/dev/geomesa/geoserver-2.15.2/"

alias geomesa-cassandra="$HOME/dev/geomesa/geomesa-cassandra_2.11-2.4.0-SNAPSHOT/bin/geomesa-cassandra"
alias geoserver="$GEOSERVER_HOME/bin/startup.sh"


#
# Environment setup
#

# gnu utils
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH-/usr/share/man}"

# Java Home
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"

# OPAM for OCaml
test -r /Users/rayzeng/.opam/opam-init/init.zsh && . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# Rust path
export PATH="$HOME/.cargo/bin:$PATH"
if command -v rustc >/dev/null 2>&1; then
  RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src";
fi

# iterm2 integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# neovim python
export NVIM_PYTHON3="/usr/local/bin/python3"
export NVIM_PYTHON2="/usr/local/bin/python2"

# cassandra
export CASSANDRA_HOME="$(where cassandra)"

# Misc ########################################################
alias del=trash

alias runhttp="python3 -m http.server 8000"

