if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
else
  set nocompatible
endif
autocmd!

" vim-plug 
" #############################################################################
call plug#begin('~/.vim/plugged')

" Utility
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-fugitive'

" Movement and search
Plug 'christoomey/vim-tmux-navigator'
Plug 'justinmk/vim-sneak'
Plug 'osyo-manga/vim-over'

" Text editing
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

" Theme
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'joshdick/onedark.vim'

" Linting and Completion
Plug 'w0rp/ale'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif

" Language plugins

" OCaml
Plug 'rgrinberg/vim-ocaml'

" Python
Plug 'zchee/deoplete-jedi'
Plug 'davidhalter/jedi-vim'

" Java
Plug 'artur-shaik/vim-javacomplete2'

" Javascript
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

set wrap
set formatoptions=jtcroql
set backspace=indent,eol,start

" Whitespace
set listchars=trail:~
nnoremap <Leader>rtw :%s/\s\+$//e<CR>

" Indentation
set autoindent
set copyindent
set sw=4 sts=4 ts=4 et

" Persistent undo
set undofile
set undodir=~/.vim/undo

" General keyboard remappings
let mapleader = ","
inoremap jk <ESC>
if exists(":tnoremap")
  tnoremap <Esc> <C-\><C-n>
endif
cnoremap w!! w !sudo tee % >/dev/null

" panes
nnoremap <leader>s <C-w>v <C-w>l
nnoremap <leader>S <C-w>s <C-w>j

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
nnoremap <silent> <leader><leader>s 
      \ :source ~/.vimrc<CR>
nnoremap <silent> <leader><leader>e
      \ :e ~/.vimrc<CR>
augroup config_ft
  autocmd!
  autocmd BufNewFile,BufRead *.sh_shared,*.sh_local set filetype=sh
  autocmd BufNewFile,BufRead zprofile,zpreztorc set filetype=zsh
autocmd FileType zsh,sh,vim,nvim setl sw=2 sts=2 ts=2 et
augroup END

" plugin-config
" #############################################################################

" FZF
function! s:ag_find(name, dir, bang)
  let l:opts = {}
  let l:opts.source = 'ag --hidden --ignore=.git -g "" ' . a:dir
  call fzf#run(fzf#wrap(a:name, l:opts, a:bang))
endfunction

command! -nargs=? -complete=dir -bang FZFAg
  \ call s:ag_find('cp-ag', <q-args>, <bang>0)

nmap <C-p> :FZF
nmap <M-p> :FZFAg

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

" sneak
let g:sneak#label = 1

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
nmap <leader>aa <Plug>(ale_lint)
nmap <leader>ar <Plug>(ale_reset_buffer)
nmap <leader>ad <Plug>(ale_detail)
nmap <leader>an <Plug>(ale_next_wrap)
nmap <leader>aA <Plug>(ale_previous_wrap) 
" deoplete
let g:deoplete#enable_at_startup = 1
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
nnoremap <leader>G :call jedi#goto()<CR>

" Java
let g:deoplete#omni#input_patterns.java = '[^. *\t]\.\w*'
autocmd FileType java,jflex setl omnifunc=javacomplete#Complete
autocmd FileType java,jflex setl sw=4 sts=4 ts=4 et

" Javascript
autocmd FileType javascript setl sw=4 sts=4 ts=4 et

" HTML
autocmd FileType html setl sw=2 sts=2 ts=2 et

