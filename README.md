# Install Notes
===============
Run `git submodule init` and `git submodule update` to set up clone.

## Environment setup
--------------------
    1. Terminal emulator [iTerm2](https://www.iterm2.com/)
	- iTerm2 configurations are saved in /iterm
	- Install One Dark theme
	    * [iTerm](https://github.com/nathanbuchar/atom-one-dark-terminal)
	    * [Gnome Terminal](https://github.com/denysdovhan/one-gnome-terminal)
	    * See scripts folders
    2. Dependencies
	- Get [brew](https://brew.sh/)
	- macOS: use /dependecies/Brewfile with `brew bundle install`
	- short list of packages
	    * `stow fortune tmux tree git python python3 exfat-fuse exfat-utils`
	    * nnn:
		    ```sh
		    brew install nnn
		    sudo add-apt-repository ppa:twodopeshaggy/jarun
		    ```
	    * safe trash:
		    ```sh
		    brew install trash
		    sudo apt-get install trash-cli
		    ```
    3. Language setups
	- Python:
	    * Just use brew python and/or Conda
	    * pip install pynvim jedi pylint
	    * If so inclined: [pyenv setup reference](https://medium.com/@henriquebastos/the-definitive-guide-to-setup-my-python-workspace-628d68552e14)
	- Rust
	    * [Installation](https://www.rust-lang.org/en-US/install.html)
		```sh
		cargo install racer
		rustup component add rust-src
		```
	- OCaml
	    * [CS 3110 OCaml installation notes](http://www.cs.cornell.edu/courses/cs3110/2017fa/install.html)
	    * [General install instructions](https://ocaml.org/docs/install.html)
	    * Probably also want core and lwt
    4. zsh
	- macOS: `brew install zsh zsh-completions`
	- linux: use package manager of choice
	- set zsh default: `chsh -s $(which zsh)`
	    * May need to add path to zsh to /etc/shells
	- stow configuration into home directory
    5. tmux (optional)
	- stow configuration into home directory
	- Run `<leader>I` to install plugins
    6. (neo)vim
	- macOS: `brew install neovim`
	- linux: use package manager of choice
	- install python dependencies: `pip[3] install pynvim`
	- for configuration: `mkdir ~/.config/nvim && stow -t ~/.config/nvim ~/.dotfiles/nvim`
	- In nvim run `:PlugInstall` and `:UpdateRemotePlugins`
	- Symlinks should make running vim interchangable with neovim
	    * use stow to copy preset symlinks
	    * undodir is not set explicitly for vim
