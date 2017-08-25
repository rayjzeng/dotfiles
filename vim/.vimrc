" Specify plugin directory
call plug#begin('~/.vim/plugged')

Plug 'chriskempson/base16-vim'
Plug 'https://github.com/ctrlpvim/ctrlp.vim.git'
Plug 'scrooloose/syntastic'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jiangmiao/auto-pairs'
Plug 'def-lkb/ocp-indent-vim'
Plug 'jeetsukumaran/vim-buffergator'

" Initialize plugin system
call plug#end()

" System Settings
set nocompatible
set encoding=utf-8
set hidden
filetype plugin indent on
set shell=/bin/bash
set wildmenu
set wildmode=list:longest
set visualbell
set ttyfast
set noundofile
set mouse=a

" Visual Settings
syntax on
set showcmd
set showmode
set laststatus=2
set number
set wrap
set scrolloff=3
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" Text editing settings
set formatoptions=qrn1
set backspace=indent,eol,start
set autoindent
set copyindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" Search settings
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set showmatch
set hlsearch
set incsearch
nnoremap <esc> :noh<return><esc>

"Keyboard Remappings
nnoremap ; :
inoremap jk <ESC>
let mapleader = ","

nnoremap <C-A> ^
inoremap <C-A> <esc>^a
vnoremap <C-A> ^
nnoremap <C-E> $
inoremap <C-E> <esc>$a
vnoremap <C-E> $

nnoremap <leader><C-Y> "+yy
vnoremap <leader><C-Y> "+y
nnoremap <leader><C-P> "+p

nmap <leader>S :source ~/.vimrc<CR>
nmap <leader>nt :NERDTreeToggle<CR>
nmap <leader>me :MerlinErrorCheck<CR>

" base16
let base16colorspace=256  " Access colors present in 256 colorspace

" NERDTree
let NERDTreeShowHidden = 1

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_ocaml_checkers = ['merlin']

" Fixing arrow keys for tmux
map OD <Left>
map OA <Up>
map OC <Right>
map OB <Down>
map [1;2D <S-Left>
map [1;2A <S-Up>
map [1;2C <S-Right>
map [1;2B <S-Down>

" Autosave
au FocusLost * :wa

" ## added by OPAM user-setup for vim / base ## 93ee63e278bdfc07d1139a748ed3fff2 ## you can edit, but keep this line
let s:opam_share_dir = system("opam config var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

let s:opam_configuration = {}

function! OpamConfOcpIndent()
  execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

function! OpamConfOcpIndex()
  execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

function! OpamConfMerlin()
  let l:dir = s:opam_share_dir . "/merlin/vim"
  execute "set rtp+=" . l:dir
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_check_cmdline = ["opam list --installed --short --safe --color=never"] + s:opam_packages
let s:opam_available_tools = split(system(join(s:opam_check_cmdline)))
for tool in s:opam_packages
  " Respect package order (merlin should be after ocp-index)
  if count(s:opam_available_tools, tool) > 0
    call s:opam_configuration[tool]()
  endif
endfor

" ## end of OPAM user-setup addition for vim / base ## keep this line
" ## added by OPAM user-setup for vim / ocp-indent ## 5e0d7f0e8662d26d5d6eee52911401a8 ## you can edit, but keep this line
if count(s:opam_available_tools,"ocp-indent") == 0
  source "/home/ray_zeng/.opam/4.05.0/share/vim/syntax/ocp-indent.vim"
endif
" ## end of OPAM user-setup addition for vim / ocp-indent ## keep this line
