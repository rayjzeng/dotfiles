if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
else
  set nocompatible
endif
autocmd!

"vim-plug 
" #############################################################################
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
Plug 'artur-shaik/vim-javacomplete2', { 'for': ['java', 'jflex'] }
Plug 'pangloss/vim-javascript'

call plug#end()


" general-config 
" #############################################################################
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
      \ :e ~/.vimrc<CR>
augroup config_ft
  autocmd!
  autocmd BufNewFile,BufRead *.sh_shared,*.sh_local set filetype=sh
autocmd FileType zsh,sh,vim,nvim setl sw=2 sts=2 ts=2 et
augroup END

" plugin-config
" #############################################################################

" FZF
let g:fzf_command_prefix = 'CtrlP'
let g:fzf_buffers_jump = 1

function! s:ag_find(name, dir, bang)
  let l:opts = {}
  let l:opts.source = 'ag --hidden --ignore=.git -g "" ' . a:dir
  call fzf#run(fzf#wrap(a:name, l:opts, a:bang))
endfunction

command! -nargs=? -complete=dir -bang CtrlP
  \ call s:ag_find('cp-ag', <q-args>, <bang>0)

nmap <C-p> :CtrlP

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

function! s:ale_toggle()
  if g:ale_enabled
    echo "Disabling ALE."
  else
    echo "Enabling ALE."
  endif
  execute 'ALEToggle'
endfunction

nmap <F2> :call <SID>ale_toggle()<CR>
nmap <C-n>l <Plug>(ale_lint)
nmap <C-n>r <Plug>(ale_reset_buffer)
nmap <C-n>d <Plug>(ale_detail)
nmap <C-n>a <Plug>(ale_next_wrap)
nmap <C-n>A <Plug>(ale_previous_wrap)

" deoplete
let g:deoplete#enable_at_startup = 0
let g:deoplete#disable_auto_complete = 0
let g:deoplete#enable_smart_case = 1
let g:deoplete#file#enable_buffer_path = 1

let g:deoplete#omni#input_patterns = {}
let g:deoplete#ignore_sources = {}

let s:deo_enabled = 0
function! s:deo_toggle()
  if s:deo_enabled
    echo 'Disabling deoplete.'
  else
    echo 'Enabling deoplete.'
  endif
  let s:deo_enabled = !s:deo_enabled
  call deoplete#toggle()
endfunction
command! DeoToggle call s:deo_toggle()

function! s:deo_auto_toggle()
  let l:ac = g:deoplete#disable_auto_complete
  if !l:ac
    echo 'Disabling autocomplete.'
  else
    echo 'Enabling autocomplete.'
  endif
  let g:deoplete#disable_auto_complete = !g:deoplete#disable_auto_complete
endfunction
command! DeoAutoToggle call s:deo_auto_toggle()

nmap <F3> :DeoToggle<CR>
imap <F3> <C-o><F3>

inoremap <silent><expr> <C-p> deoplete#mappings#manual_complete()
inoremap <silent><expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
inoremap <silent><expr> <C-g> deoplete#undo_completion()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB>
      \ pumvisible() ? "\<C-p>" : "\<S-TAB>"


" lang-config
" #############################################################################

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

function! s:OCamlConf()
  if s:opam
    nnoremap <leader>me :MerlinErrorCheck<CR>
    nnoremap <leader>to :MerlinTypeOf<CR>
    nnoremap <leader>gt :MerlinLocate<CR>
  endif
  setl sw=2 sts=2 ts=2 et
endfunction

autocmd FileType ocaml call s:OCamlConf()

" Python
autocmd FileType python setl sw=4 sts=4 ts=4 et
let g:jedi#completions_enabled = 0

" Rust
autocmd FileType rust setl sw=4 sts=4 ts=4 et
let g:racer_cmd = "~/.cargo/bin/racer"
let g:racer_experimental_completer = 1

"JFlex
augroup filetype
  autocmd BufRead,BufNewFile *.flex,*.jflex set filetype=jflex         
augroup END                                                          
autocmd Syntax jflex source ~/.vim/syntax/jflex.vim

" Java:
let g:deoplete#omni#input_patterns.java = '[^. *\t]\.\w*'
autocmd FileType java,jflex setl omnifunc=javacomplete#Complete
autocmd FileType java,jflex setl sw=4 sts=4 ts=4 et

" Javascript
autocmd FileType javascript setl sw=2 sts=2 ts=2 et

" HTML
autocmd FileType html setl sw=2 sts=2 ts=2 et


" project-config
" #############################################################################
let s:sources = ["bin", "lib/*"]
let s:comp_dir = "/Users/rayzeng/Development/4120/xic"
function! s:Compilers()
  let l:s = []
  for i in range(0, len(s:sources) - 1)
    call add(l:s, s:comp_dir . "/" . s:sources[i])
  endfor
  let g:ale_java_javac_classpath = join(l:s, ":")
endfunction

autocmd BufNewFile,BufRead */4120/xic/* call s:Compilers()
