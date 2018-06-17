# Install Notes
Run `git submodule init` and `git submodule update` to set up clone.

## Environment setup
1. [iTerm2](https://www.iterm2.com/) or terminal emulator of choice
    - iTerm2 configurations are saved in /iterm
	- Install One Dark theme
	 	* [iTerm/Terminal](https://github.com/nathanbuchar/atom-one-dark-terminal)
		* [Gnome Terminal](https://github.com/denysdovhan/one-gnome-terminal)
		* See scripts folders
2. Dependencies
    - Get [brew](https://brew.sh/)
    - use /dependecies/Brewfile with `brew bundle install`
	- OR sudo apt-get `stow fortune tmux tree git python python3 exfat-fuse exfat-utils` (refer to brewFile for more)
	- nnn:
		```sh
		brew install nnn
		sudo add-apt-repository ppa:twodopeshaggy/jarun
		```
	- safe trash:
		```sh
		brew install trash
		sudo apt-get install trash-cli
		```
3. Language setups
	- Python:
	    * Just use brew python
	    * pip install neovim jedi pylint
		* If so inclined: [pyenv setup reference](https://medium.com/@henriquebastos/the-definitive-guide-to-setup-my-python-workspace-628d68552e14)
	- Rust
		* [Installation](https://www.rust-lang.org/en-US/install.html)
			```sh
			cargo install racer
			rustup component add rust-src
			```
	- OCaml
		* [CS 3110 notes](http://www.cs.cornell.edu/courses/cs3110/2017fa/install.html)
		* [General install instructions](https://ocaml.org/docs/install.html)
		* Probably also want core and lwt
4. zsh
	- install: `brew install zsh zsh-completions` or `sudo apt-get install zsh`
	- set zsh default: `chsh -s $(which zsh)`
	    * May need to add path to zsh to /etc/shells
	- stow configuration into home directory
	- Initialize and update zprezto submodule
	    * Don't forget to switch to the proper branch from the origin
	- copy configuration files for prezto
		```sh
		 setopt EXTENDED_GLOB
		 for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
		   ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
		 done
		 ```
5. tmux
    - stow configuration into home directory
	- Run `<leader>I` to install plugins
6. (neo)vim
	- nvim:
		- use `brew install neovim` or
			```sh
			sudo add-apt-repository ppa:neovim-ppa/stable
			sudo apt-get update
			sudo apt-get install neovim
			```
	- install python dependencies: `pip(3) install neovim`
	- for configuration: `mkdir ~/.config/nvim && stow -t ~/.config/nvim ~/.dotfiles/nvim`
	- In nvim run `:PlugInstall` and `:UpdateRemotePlugins`
	- Symlinks should make running vim interchangable with neovim
	    * undodir is not set explicitly for vim
