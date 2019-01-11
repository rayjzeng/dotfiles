# Install Notes
===============
Clone into `$HOME/dotfiles`.
Run `git submodule init` and `git submodule update --recursive` to set up 
submodules.

## Common Environment setup
---------------------------

### Install dependencies
- macOS:
    * Get [brew][1]
    * use /dependecies/Brewfile with `brew bundle install`
- arch:
    * Install yay `pacman -S yay`
- (incomplete) list of needed packages [TODO: make list for arch]
    * rg
    * fd
    * stow
    * git
    * python(2/3)
- to have safe trash install (and update .local.sh):
    * brew name: trash
    * arch pkg: trash-cli

#### Quick reminder on using stow
- See `man stow`
- General command `stow -t [target dir] -d [stow dir] [pkg name]`
- target directory defaults to parent of stow directory

### Get zsh
zsh configuration currently makes use of [zim][2].

- macOS: `brew install zsh zsh-completions`
- arch: `yay -S zsh zsh-completion`
- set zsh default: `chsh -s $(which zsh)`
    * May need to add path to zsh to /etc/shells
- stow `stow zsh`

### Terminal emulators
- [iTerm2][3]
- [kitty][4]
- Install themes (see scripts folder)
    * One Dark
    * Snazzy

### Install (neo)vim
- macOS: `brew install neovim` (consider also installing macvim)
- arch: `yay -S neovim gvim`
- install python dependencies: `pip[3] install pynvim`
- for configuration: 
    `mkdir ~/.config/nvim && stow -t ~/.config/nvim -d $DOT_DIR nvim`
- In nvim run `:PlugInstall` and `:UpdateRemotePlugins`
- Symlinks should make running vim interchangable with neovim
    * Current limitations [TODO make config compatible]
	+ undodir is not set explicitly for vim
	+ deoplete and remote plugins are not available

### Get tmux (optional)
- Install with package manager of choic
- `stow tmux`
- Run `<leader>I` to install plugins

### Install language support
- Python:
    * Just use brew python and/or Conda
    * pip install pynvim jedi pylint
    * If so inclined: [pyenv setup reference][5]
- Rust
    * [Installation][6]
	```sh
	cargo install racer
	rustup component add rust-src
	```
- OCaml
    * Check out the CS 3110 OCaml installation notes
    * [General install instructions][7]
    * Probably also want core/lwt and other libraries

## Arch Details
---------------
Currently i3 config is saved. More to come.

[1]: https://brew.sh/
[2]: https://github.com/zimfw/zimfw
[3]: https://www.iterm2.com/
[4]: https://sw.kovidgoyal.net/kitty/
[5]: https://medium.com/@henriquebastos/the-definitive-guide-to-setup-my-python-workspace-628d68552e14
[6]: https://www.rust-lang.org/en-US/install.html
[7]: https://ocaml.org/docs/install.html
