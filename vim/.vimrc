set nocompatible
filetype off

" vim-plug
" Specify plugin directory
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}

Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'def-lkb/ocp-indent-vim', {'for': 'ocaml'}
Plug 'scrooloose/syntastic'
Plug 'Valloric/YouCompleteMe'

" Initialize plugin system
call plug#end()


" #### vim general settings
filetype plugin indent on
set encoding=utf-8
set hidden
set shell=/bin/bash
set wildmenu
set wildmode=list:longest
set visualbell
set ttyfast
set noundofile
au FocusLost * :wa

" Visual Settings
syntax on
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
set showcmd
set laststatus=2
set number
set relativenumber
"set cursorline
set scrolloff=1

set wrap
set formatoptions=qrn1
set colorcolumn=85

set listchars=trail:~
"set list

" Text editing settings
set mouse=a
set backspace=indent,eol,start
set autoindent
set copyindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" General keyboard remappings
let mapleader = ","
nnoremap ; :
inoremap jk <ESC>

" Config editing
nnoremap <leader>vs :source ~/.vimrc<CR>
nnoremap <leader>ve :tabnew ~/.vimrc<CR>
autocmd FileType shell_aliases set syntax=sh
autocmd FileType sh_aliases set syntax=sh

" Windows and tabs
nnoremap <leader><C-t> :tabnew<CR>
nnoremap <leader><C-n> :enew<CR>
nnoremap <leader>wq :w<CR>:bd<CR>
nnoremap <leader>wv <C-w>v <C-w>l
nnoremap <leader>ws <C-w>s <C-w>j
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Emacs like start/end of line
nnoremap <C-A> ^
inoremap <C-A> <esc>^a
vnoremap <C-A> ^
nnoremap <C-E> $
inoremap <C-E> <esc>$a
vnoremap <C-E> $

" System clipboard
nnoremap <C-c> "+yy
vnoremap <C-c> "+y
nnoremap <leader>p "+p

" Search settings
nnoremap / /\v
vnoremap / /\v
nnoremap <silent> <leader><space> :noh<CR>
set ignorecase
set smartcase
set showmatch
set hlsearch
set incsearch
nnoremap \ :%s/
nnoremap <Leader>rtw :%s/\s\+$//e<CR>


" #### plugins

" ack.vim
let g:ackprg = 'ag --vimgrep'

" NERDTree
let NERDTreeShowHidden = 1
nnoremap <leader>nt :NERDTreeToggle<CR>

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" syntastic
nnoremap <leader>se :SyntasticCheck<CR>:Errors<CR>
nnoremap <silent> <leader>sc :lclose<CR>
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_loc_list_height = 5
let g:syntastic_ocaml_checkers = ['merlin']

let g:syntastic_python_flake8_exec = '/usr/local/bin/flake8'
let g:syntastic_python_checkers = ['pyflakes', 'python3']

" YCM
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_semantic_triggers =  {
  \   'c' : ['->', '.'],
  \   'objc' : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s',
  \             're!\[.*\]\s'],
  \   'ocaml' : ['.', '#', 're![^\s]+'],
  \   'cpp,objcpp' : ['->', '.', '::'],
  \   'perl' : ['->'],
  \   'php' : ['->', '::'],
  \   'cs,java,javascript,typescript,d,python,perl6,scala,vb,elixir,go' : ['.'],
  \   'ruby' : ['.', '::'],
  \   'lua' : ['.', ':'],
  \   'erlang' : [':'],
  \ }
let g:ycm_key_invoke_completion = '<C-k>'
let g:ycm_key_list_stop_completion = ['<C-y>']
let g:ycm_python_binary_path = '/usr/bin/python'

" Fixing arrow keys for tmux
map OD <Left>
map OA <Up>
map OC <Right>
map OB <Down>
map [1;2D <S-Left>
map [1;2A <S-Up>
map [1;2C <S-Right>
map [1;2B <S-Down>


" #### Language specific settings

" OCaml
nnoremap <leader>me :MerlinErrorCheck<CR>
autocmd FileType ocaml setl sw=2 sts=2 ts=2 et

set rtp+=~/.vim/plugged/ocp-indent-vim

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

