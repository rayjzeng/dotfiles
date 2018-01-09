if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
else
  set nocompatible
endif
autocmd!

"vim-plug #####################################################
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'christoomey/vim-tmux-navigator'

Plug 'Raimondi/delimitMate'
Plug 'tomtom/tcomment_vim'
Plug 'osyo-manga/vim-over'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'joshdick/onedark.vim'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'w0rp/ale'

Plug 'rgrinberg/vim-ocaml', { 'for': 'ocaml' }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'racer-rust/vim-racer', { 'for': 'rust' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }

call plug#end()


" general configuration #######################################
filetype plugin indent on
set ttyfast
set wildmenu
set encoding=utf-8
if executable('zsh')
  set shell=/bin/zsh
else
  set shell=/bin/bash
endif
set hidden
set mouse=a

let s:pyenv=$PYENV_ROOT
let g:python_host_prog=s:pyenv . '/versions/neovim2/bin/python'
let g:python3_host_prog =s:pyenv . '/versions/neovim3/bin/python'

" Visual Settings
syntax on
set visualbell
set showcmd
set laststatus=2
set scrolloff=1
set colorcolumn=80
set cursorline

if $TERM =~ '.*256.*'
  set termguicolors
endif
let g:onedark_termcolors=16
colorscheme onedark

set number
augroup numbering
  autocmd!
  autocmd InsertEnter * set norelativenumber
  autocmd InsertLeave * set relativenumber
augroup END

set listchars=trail:~
nnoremap <Leader>rtw :%s/\s\+$//e<CR>

set wrap
set formatoptions=jtcroql
set backspace=indent,eol,start
set autoindent
set copyindent
set sw=4 sts=4 ts=4

" General keyboard remappings
let mapleader = ","
nnoremap ; :
inoremap jk <ESC>
if exists(":tnoremap")
  tnoremap <Esc> <C-\><C-n>
endif
cmap w!! w !sudo tee % >/dev/null

" panes
nnoremap <leader>d <C-w>v <C-w>l
nnoremap <leader>D <C-w>s <C-w>j

" Emacs like start/end of line
inoremap <C-A> <C-o>I
vnoremap <C-A> ^
inoremap <C-E> <C-o>A
vnoremap <C-E> $

" System clipboard
nnoremap <leader>yy "+yy
vnoremap <leader>y "+y
nnoremap <leader>dd "+dd
vnoremap <leader>d "+d
nnoremap <leader>p "+p

" Search settings
nnoremap / /\v
vnoremap / /\v
nnoremap <silent> <leader>h :noh<CR>
set ignorecase
set smartcase
set showmatch
set hlsearch
set incsearch
nnoremap \ :OverCommandLine<CR>%s/

" config editing
nnoremap <silent> <leader>rs 
      \ :source ~/.vimrc<CR>
nnoremap <silent> <leader>re
      \ :tabedit ~/.vimrc<CR>
augroup config_ft
  autocmd!
  autocmd BufNewFile,BufRead *.sh_shared,*.sh_local set filetype=sh
autocmd FileType zsh,sh,vim,nvim setl sw=2 sts=2 ts=2 et
augroup END

" Plugins
source ~/.vim/init/plugins.vim 

" Language specific settings
source ~/.vim/init/langs.vim

