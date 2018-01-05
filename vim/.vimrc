set nocompatible
autocmd!

" vim-plug
" Specify plugin directory
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'christoomey/vim-tmux-navigator'

Plug 'Raimondi/delimitMate'
Plug 'tomtom/tcomment_vim'
Plug 'osyo-manga/vim-over'

Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'joshdick/onedark.vim'

Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/syntastic'
Plug 'Valloric/YouCompleteMe'

" Initialize plugin system
call plug#end()


" #### vim general settings
filetype plugin indent on
set encoding=utf-8
if executable("zsh")
    set shell=/bin/zsh
else
    set shell=/bin/bash
endif
set wildmenu
set wildmode=list:longest
set visualbell
set ttyfast

" Visual Settings
syntax on
colorscheme onedark
let g:onedark_termcolors=16
set showcmd
set laststatus=2

set number
augroup numbering
  autocmd!
  autocmd InsertEnter * set norelativenumber
  autocmd InsertLeave * set relativenumber
augroup END
set scrolloff=1
set colorcolumn=80

set listchars=trail:~
nnoremap <Leader>rtw :%s/\s\+$//e<CR>

set hidden
set wrap
set formatoptions=qrn1
set mouse=a
set backspace=indent,eol,start
set autoindent
set copyindent
set sw=4 sts=4 ts=4

" General keyboard remappings
let mapleader = ","
nnoremap ; :
inoremap jk <ESC>

" panes
nnoremap <leader>d <C-w>v <C-w>l
nnoremap <leader>D <C-w>s <C-w>j

" Emacs like start/end of line
" nnoremap <C-A> ^
inoremap <C-A> <esc>^a
vnoremap <C-A> ^
" nnoremap <C-E> $
inoremap <C-E> <esc>$a
vnoremap <C-E> $

" System clipboard
nnoremap <leader>yy "+yy
vnoremap <leader>y "+y
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
nnoremap <leader>rcs :source ~/.vimCR>
nnoremap <leader>rce :tabnew ~/.vim<CR>
augroup filetype_config
  autocmd!
  autocmd BufNewFile,BufRead *.sh_shared,*.sh_local set filetype=sh
  autocmd FileType vim,nvim,zsh,sh setl sw=2 sts=2 ts=2 et
augroup END

" Fixing arrow keys for tmux
map OD <Left>
map OA <Up>
map OC <Right>
map OB <Down>
map [1;2D <S-Left>
map [1;2A <S-Up>
map [1;2C <S-Right>
map [1;2B <S-Down>


" #### plugins

" NERDTree
let NERDTreeShowHidden = 1
nnoremap <leader>n :NERDTreeToggle<CR>

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#right_sep = ' '
let g:airline#extensions#tabline#right_alt_sep = '|'
let g:airline_left_sep = ' '
let g:airline_left_alt_sep = '|'
let g:airline_right_sep = ' '
let g:airline_right_alt_sep = '|'
let g:airline_theme='onedark'

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
let g:syntastic_python_checkers = ['pyflakes', 'python3']

" YCM
let g:ycm_min_num_of_chars_for_completion = 99
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_semantic_triggers =  {
  \   'c' : ['->', '.'],
  \   'objc' : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s',
  \             're!\[.*\]\s'],
  \   'ocaml' : ['.', '#'],
  \   'cpp,objcpp' : ['->', '.', '::'],
  \   'perl' : ['->'],
  \   'php' : ['->', '::'],
  \   'cs,java,javascript,typescript,d,python,perl6,scala,vb,elixir,go' : ['.'],
  \   'ruby' : ['.', '::'],
  \   'lua' : ['.', ':'],
  \   'erlang' : [':'],
  \ }
let g:ycm_key_invoke_completion = '<C-p>'
let g:ycm_key_list_stop_completion = ['<C-g>']
let g:ycm_python_binary_path = 'python'


" #### Language specific settings

" OCaml
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

function! OCamlConf()
  nnoremap <leader>me :MerlinErrorCheck<CR>
  nnoremap <leader>to :MerlinTypeOf<CR>
  nnoremap <leader>gt :MerlinLocate<CR>
  setl sw=2 sts=2 ts=2 et
endfunction

autocmd FileType ocaml :execute OCamlConf()

" Python
autocmd FileType python setl sw=4 sts=4 ts=4 et
