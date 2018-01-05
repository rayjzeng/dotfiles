# Install Notes
1. iTerm2 (https://www.iterm2.com/)
2. brew (https://brew.sh/) or apt-get
    - stow, fortune, tmux, trash, tree, git, nnn
3. stow
    - stow for nvim, tmux, zsh
2. Languages
    - Python:
        * Conda (https://conda.io/miniconda.html)
        * apt-get
        * `pip install jedi pylint`
    - Rust
        * https://www.rust-lang.org/en-US/install.html
        * `cargo install racer`
        * `rustup component add rust-src`
    - OCaml
        * http://www.cs.cornell.edu/courses/cs3110/2017fa/install.html
        * https://ocaml.org/docs/install.html
3. ZSH 
    - `brew install zsh zsh-completions` or `sudo apt-get install zsh`
    - `chsh -s /bin/zsh`
    - One Dark
        * iTerm/Terminal: https://github.com/nathanbuchar/atom-one-dark-terminal
        * Gnome: https://github.com/denysdovhan/one-gnome-terminal
4. tmux
    - Run `<leader>I` to install plugins
5. Neovim
    - nvim:
        * `brew install neovim`
        * `sudo add-apt-repository ppa:neovim-ppa/stable` \
            `sudo apt-get update` \
            `sudo apt-get install neovim`
    - `pip install neovim`
    - `stow -t ~/.config ~/.dotfiles/nvim`
    - In nvim run `:PlugInstall`