# Install Notes
---------------

## Getting started
------------------
Assume that `brew` and `git` are already installed

Set up Github [ssh keys and configure ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
```sh
eval "$(ssh-agent -s)"
ssh-keygen -t ed25519 -C "zeng.j.ray@gmail.com"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
cat << 'EOF' > ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
```
Clone the repo
```sh
git clone --recurse-submodules git@github.com:rayjzeng/dotfiles.git $HOME/dotfiles
git submodule init
git submodule update --recursive
```

Install packages
```sh
cd ./dependencies
brew bundle install
```

## Common Environment setup
---------------------------
```sh
cd ~/dotfiles
stow tmux
stow vim
stow -t $HOME/.config/wezterm wezterm
stow zsh
```

### Quick reminder on using stow
- `stow -t [target dir] -d [stow dir] [pkg name]`
- Defaults
    - target dir: parent of stow dir
    - stow dir: current dir

### zsh
- macOS: `brew install zsh` or use built in zsh
- Configuration: `stow -t $HOME -d $HOME/dotfiles zsh`
- Run `zkbd` on first launch of each terminal emulator (tmux-256color can be copied directly from xterm-256color)

## Manual steps 
---------------

### iTerm2
- [iTerm2](https://www.iterm2.com/) settings must be configured in UI

### fzf integration
```
source <(fzf --zsh)
```
See docs at [fzf](https://github.com/junegunn/fzf)

### vim configuration
- Run `:PlugInstall` on first use

### tmux
- Leader is currently set to default \<C-b\>
- Run `<leader>I` to install plugins

## Manual dependency updates 
----------------------------

### zsh/.zmodules/third-party
These zsh modules need to be updated manually but should be relatively stable:
- [curl completions](https://github.com/curl/curl/blob/master/scripts/completion.pl)
- [bash completions](https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.bash)