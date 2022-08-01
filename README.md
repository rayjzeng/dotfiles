# Install Notes
---------------
Get Git and set up ssh keys/configure ssh-agent and then run:
```sh
git clone --recurse-submodules git@github.com:rayjzeng/dotfiles.git $HOME/dotfiles
```

Don't forget to run `git submodule init` and `git submodule update --recursive`.

## Common Environment setup
---------------------------

### Install dependencies
- macOS:
    * Get [brew](https://brew.sh/)
    * use `/dependecies/Brewfile` with `brew bundle install`
- Some needed packages (refer to Brewfile on macOS)
    * fd
    * fzf
    * git
    * node
    * python
    * rg
    * stow
    * tmux
    * vim
- to have safe trash install (and update .local.sh with aliases):
    * brew name: trash

#### Quick reminder on using stow
- See `man stow`
- General command `stow -t [target dir] -d [stow dir] [pkg name]`
- Note: target directory defaults to parent of stow directory and
    stow directory defaults to current directory

### zsh
- macOS: `brew install zsh` or use built in zsh
- Configuration: `stow -t $HOME -d $HOME/dotfiles zsh`
- You will need to run `zkbd` for each terminal emulator (including for tmux)

#### Manual dependencies in zsh/.zmodules/third-party
-----------------------------------------------------
These need to be updated manually but should be relatively stable:
- [Curl zsh completions](https://github.com/curl/curl/blob/master/scripts/completion.pl)

### Terminal
- Point [iTerm2](https://www.iterm2.com/) settings backup to appropriate directory

### vim configuration
- For configuration: 
    ```sh
    mkdir -p ~/.config/nvim && stow -t $HOME/.config/nvim -d $HOME/dotfiles nvim
    stow -t $HOME -d $HOME/dotfiles vim
    ```
- Run `:PlugInstall`

#### Neovim
Currently, the philosophy in my vim configuration is to minimize external
dependencies for better xplat compatability. This also means preferring vim
over Neovim.

### tmux
- Install a relatively recent version with package manager of choice
- Stow configuration: `stow -t $HOME -d $HOME/dotfiles tmux`
- Leader is currently set to default \<C-b\>
- Run `<leader>I` to install plugins

### Install language support
- Python:
    * Just use brew for system-wide Python
    * `pip install jedi pylint`
    * If more complex environment management is needed consider using pyenv
- Rust
    * [Installation](https://www.rust-lang.org/tools/install)
	```sh
	cargo install racer
	rustup component add rust-src
	```
- OCaml
    * [General install instructions](https://ocaml.org/docs/install.html)
    * Potentially avoid brew for X11 support on Mac
