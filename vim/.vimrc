if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
else
  set nocompatible
endif
autocmd!

" #############################################################################
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

" Statusline
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'

" Theme
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
Plug 'copy/deoplete-ocaml'
Plug 'rgrinberg/vim-ocaml'

" Python
Plug 'zchee/deoplete-jedi'
Plug 'davidhalter/jedi-vim'

" Java
Plug 'artur-shaik/vim-javacomplete2'

" Javascript
Plug 'pangloss/vim-javascript'

call plug#end()


" #############################################################################
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

" Set python environments
let s:pyenv=$PYENV_ROOT
let g:python_host_prog=s:pyenv . '/versions/neovim2/bin/python'
let g:python3_host_prog =s:pyenv . '/versions/neovim3/bin/python'

" Visual settings
syntax on
set visualbell
set showcmd
set laststatus=2
set scrolloff=1
set colorcolumn=80
set cursorline

" Color mode and scheme
if $TERM =~ '.*256.*'
  set termguicolors
endif
let g:onedark_termcolors=16
colorscheme onedark

" Line numbering
set number
augroup numbering
  autocmd!
  autocmd InsertEnter * set norelativenumber
  autocmd InsertLeave * set relativenumber
augroup END

" Line wrapping
set wrap
set formatoptions=jtcroql

" Whitespace
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
nnoremap <leader><leader>r :%s/\s\+$//e<CR>

" Sane backspace behavior
set backspace=indent,eol,start

" Indentation
set autoindent
set copyindent
set sw=4 sts=4 ts=4 et

" Undo, swap, backup
set undofile
set undodir=$HOME/.vim/undo//
set directory=$HOME/.vim/swp//
set backupdir=$HOME/.vim/backup//

" General keyboard remappings
let mapleader = ' '
inoremap jk <ESC>
nnoremap Q @@

" Esc in nvim terminal
" if exists(":tnoremap")
"   tnoremap <Esc> <C-\><C-n>
" endif

" Open current buffer as root
cnoremap w!! w !sudo tee % >/dev/null

" Easy buffer switching
nnoremap <silent> gb :bn<CR>
nnoremap <silent> gB :bp<CR>

" Panes
nnoremap <leader>v <C-w>v <C-w>l
nnoremap <leader>s <C-w>s <C-w>j

" Emacs like start/end of line
inoremap <C-A> <C-o>I
vnoremap <C-A> ^
inoremap <C-E> <C-o>A
vnoremap <C-E> $

" System clipboard integration
nnoremap <leader>yy "+yy
vnoremap <leader>y "+y
nnoremap <leader>dd "+dd
vnoremap <leader>d "+d
nnoremap <leader>p "+p

" Better search
nnoremap / /\v
vnoremap / /\v
nnoremap <silent> <leader><leader>n :noh<CR>
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

" #############################################################################
" plugin-config
" #############################################################################

" ALE
" #############################################################################
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1

function! s:ale_toggle()
  if g:ale_enabled
    echo "Disabling ALE."
  else
    echo "Enabling ALE."
  endif
  execute 'ALEToggle'
endfunction
nmap <F4> :call <SID>ale_toggle()<CR>

" Linting shortcuts
nmap <leader>al <Plug>(ale_lint)
nmap <leader>ar <Plug>(ale_reset_buffer)
nmap <leader>ad <Plug>(ale_detail)
nmap <leader>aa <Plug>(ale_next_wrap)
nmap <leader>aA <Plug>(ale_previous_wrap)


" deoplete
" #############################################################################

" Enable and toggle
let s:deo_enabled = 1
let g:deoplete#enable_at_startup = s:deo_enabled
function! s:deo_toggle()
  if s:deo_enabled
    echo 'Disabling deoplete.'
    call deoplete#disable()
  else
    echo 'Enabling deoplete.'
    call deoplete#enable()
  endif
  let s:deo_enabled = !s:deo_enabled
endfunction
command! DeoToggle call s:deo_toggle()
nmap <F2> :DeoToggle<CR>

" Set options
call deoplete#custom#option('smart_case', 1)

" Disable and toggle auto complete
let s:auto_enabled = 0
call deoplete#custom#option('auto_complete', s:auto_enabled)
function! s:deo_auto_toggle()
  if s:auto_enabled
    echo 'Disabling autocomplete.'
    call deoplete#custom#option({ 'auto_complete': 0 })
  else
    echo 'Enabling autocomplete.'
    call deoplete#custom#option({ 'auto_complete': 1 })
  endif
  let s:auto_enabled = !s:auto_enabled
endfunction
command! DeoAuto call s:deo_auto_toggle()
nmap <F3> :DeoAuto<CR>

" Keybindings
inoremap <silent><expr> <C-p> deoplete#mappings#manual_complete()
inoremap <silent><expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
inoremap <silent><expr> <C-g> deoplete#undo_completion()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB>
      \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

" Omni source config
call deoplete#custom#option('ignore_sources',
    \ {
    \   'ocaml': ['buffer', 'around', 'member', 'tag'],
    \ })


" fzf
" #############################################################################
nnoremap <C-p> :FZF<CR> 

" Some rg options
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options

" Find in directory
let s:rg_all = 'rg --column --line-number --no-heading --fixed-strings
            \ --ignore-case --no-ignore --hidden --glob "!.git/*" --color always '
command! -bang -nargs=* FFind call fzf#vim#grep(s:rg_all . shellescape(<q-args>), 1, <bang>0)
nnoremap <M-p> :FFind 

" Buffers and tabs
nnoremap <leader>b :FBuffers<CR>
nnoremap <leader>t :FWindows<CR>

" Recent files, commands, searches
nnoremap q; :FHistory<CR>
nnoremap q: :FHistory:<CR>
nnoremap q/ :FHistory/<CR>

let g:fzf_command_prefix = 'F'


" lightline
" #############################################################################

let g:lightline = { 
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left':[
      \       [ 'mode', 'paste' ],
      \       [ 'gitbranch', 'readonly', 'filename', 'modified' ],
      \     ],
      \   'right': [
      \       [ 'linter_checking', 'linter_errors', 'linter_warnings' ],
      \       [ 'lineinfo' ],
      \       [ 'percent' ],
      \       [ 'fileformat', 'fileencoding', 'filetype' ],
      \     ],
      \   },
      \ 'component_function': {
      \     'gitbranch': 'fugitive#head',
      \     'filename': 'FileNameNoFZF',
      \   },
      \ 'component_expand': {
      \     'linter_checking': 'lightline#ale#checking',
      \     'linter_warnings': 'lightline#ale#warnings',
      \     'linter_errors': 'lightline#ale#errors',
      \     'linter_ok': 'lightline#ale#ok',
      \   },
      \ 'component_type': {
      \     'linter_checking': 'left',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'left',
      \   },
      \ }

" Override filename function to hide for fzf
function! FileNameNoFZF()
  return &ft ==# 'fzf' ? '' : (expand('%:t') !=# '' ? expand('%:t') : '[No Name]')
endfunction


" sneak
" #############################################################################
let g:sneak#label = 1
map ' <Plug>Sneak_,
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T


" #############################################################################
" lang-config
" #############################################################################

" OCaml
" #############################################################################
let s:opam = 0
if executable('opam')
  let s:opamshare = substitute(system('opam config var share'),'\n$','','''')
  execute 'set rtp^=' . s:opamshare . '/ocp-indent/vim'
  execute 'set rtp+=' . s:opamshare . '/merlin/vim'
  let s:opam = 1
endif

" Configure only when writing OCaml
function! s:OCamlConf()
  if s:opam
    nnoremap <leader>me :MerlinErrorCheck<CR>
    nnoremap <leader>mt :MerlinTypeOf<CR>
    nnoremap <leader>ml :MerlinLocate<CR>
  endif
  setl sw=2 sts=2 ts=2 et
endfunction

autocmd FileType ocaml call s:OCamlConf()


" Python
" #############################################################################
let g:jedi#completions_enabled = 0
call deoplete#custom#source('jedi', 'show_docstring', 1)


" Indentation for Python
autocmd FileType python setl sw=4 sts=4 ts=4 et


" Java
" #############################################################################
" let g:deoplete#omni#input_patterns.java = '[^. *\t]\.\w*'
autocmd FileType java,jflex,cup setl omnifunc=javacomplete#Complete
autocmd FileType java,jflex,cup setl sw=4 sts=4 ts=4 et


" Javascript
" #############################################################################
autocmd FileType javascript setl sw=4 sts=4 ts=4 et


" HTML
" #############################################################################
autocmd FileType html setl sw=2 sts=2 ts=2 et

