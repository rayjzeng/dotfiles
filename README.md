# Install Notes
Be sure to init the submodules!

## Program setup
1. iTerm2 (https://www.iterm2.com/)
2. brew (https://brew.sh/) OR apt-get
    - stow, fortune, tmux, tree, git, ag
    - nnn:
        - `brew install nnn` 
        - `sudo add-apt-repository ppa:twodopeshaggy/jarun`
    - safe trash:
        - `brew install trash`
        - `sudo apt-get install trash-put`
3. Run stow
	- Into home for tmux/zsh
	- See 7. for vim
4. Language setup
    - Python:
        * From brew or https://github.com/pyenv/pyenv-installer:
			- pyenv
			- pyenv-virtualenv (https://github.com/pyenv/pyenv-virtualenv)
			- pyenv-virtualenvwrapper (https://github.com/pyenv/pyenv-virtualenvwrapper)
		* setup virtual environments
			- neovim2
			- neovim3
        * For each environment
        `pip install jedi pylint neovim`
    - Rust
        * https://www.rust-lang.org/en-US/install.html
        * `cargo install racer`
        * `rustup component add rust-src`
    - OCaml
        * http://www.cs.cornell.edu/courses/cs3110/2017fa/install.html
        * https://ocaml.org/docs/install.html
5. ZSH 
    - `brew install zsh zsh-completions` or `sudo apt-get install zsh`
    - `chsh -s /bin/zsh`
    - One Dark
        * iTerm/Terminal: https://github.com/nathanbuchar/atom-one-dark-terminal
        * Gnome: https://github.com/denysdovhan/one-gnome-terminal
        * See dependencies and scripts folders
6. tmux
    - Run `<leader>I` to install plugins
7. (neo)vim
    - nvim:
        * `brew install neovim`
        * `sudo add-apt-repository ppa:neovim-ppa/stable` \
            `sudo apt-get update` \
            `sudo apt-get install neovim`
    - `pip install neovim`
    - `stow -t ~/.config ~/.dotfiles/nvim`
    - In nvim run `:PlugInstall`
	- vim interchangable with neovim
