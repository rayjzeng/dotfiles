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

set termguicolors
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
" nnoremap <C-A> ^
inoremap <C-A> <esc>^i
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
nnoremap <silent> <leader>rcs :source ~/.vimrc<CR>
nnoremap <silent> <leader>rce :edit ~/.vimrc<CR>
augroup filetype_config
  autocmd!
  autocmd BufNewFile,BufRead *.sh_shared,*.sh_local set filetype=sh
  autocmd FileType zsh,sh,vim,nvim setl sw=2 sts=2 ts=2 et
augroup END


" #### plugins

" FZF
let g:fzf_command_prefix = 'FZF'
nnoremap <C-p> :FZF

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

" ALE
let g:airline#extensions#ale#enabled = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0

nmap <leader>at <Plug>(ale_toggle)
nmap <leader>ar <Plug>(ale_reset_buffer)
nmap <leader>ad <Plug>(ale_detail)
nmap <leader>aa <Plug>(ale_next_wrap)
nmap <leader>aA <Plug>(ale_previous_wrap)

" deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#omni#input_patterns = {}
let g:deoplete#ignore_sources = {}

inoremap <silent><expr> <C-p> deoplete#mappings#manual_complete()
inoremap <silent><expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
inoremap <silent><expr> <C-g> deoplete#undo_completion()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB>
      \ pumvisible() ? "\<C-p>" : "\<S-TAB>"


" #### Language specific settings

" OCaml
let g:deoplete#omni#input_patterns.ocaml = '[^. *\t]\.\w*|#'
let g:deoplete#ignore_sources.ocaml = ['buffer', 'around']

let s:opam = 0
if executable('opam')
  let s:opamshare = substitute(system('opam config var share'),'\n$','','''')
  execute "set rtp^=" . s:opamshare . "/ocp-indent/vim"
  execute "set rtp+=" . s:opamshare . "/merlin/vim"
  let s:opam = 1
endif

function! OCamlConf()
  if s:opam
    nnoremap <leader>me :MerlinErrorCheck<CR>
    nnoremap <leader>to :MerlinTypeOf<CR>
    nnoremap <leader>gt :MerlinLocate<CR>
  endif
  setl sw=2 sts=2 ts=2 et
endfunction

autocmd FileType ocaml :execute OCamlConf()

" Python
autocmd FileType python setl sw=4 sts=4 ts=4 et
let g:jedi#completions_enabled = 0

" Rust
autocmd FileType rust setl sw=4 sts=4 ts=4 et
let g:racer_cmd = "~/.cargo/bin/racer"
let g:racer_experimental_completer = 1
