" clear autocmd on reload
autocmd!

"vim-plug #####################################################

call plug#begin('~/.config/nvim/plugged')

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

Plug 'sheerun/vim-polyglot'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'w0rp/ale'

Plug 'rgrinberg/vim-ocaml', { 'for': 'ocaml' }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'racer-rust/vim-racer', { 'for': 'rust' }

call plug#end()


" general configuration #######################################
set visualbell
set termguicolors
let g:onedark_termcolors=16
colorscheme onedark

set cursorline
set guicursor=

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
set mouse=a
set autoindent
set copyindent
set sw=4 sts=4 ts=4

" General keyboard remappings
let mapleader = ","
nnoremap ; :
inoremap jk <ESC>
tnoremap <Esc> <C-\><C-n>

" emacs like goto start/end of line
" nnoremap <C-A> ^
inoremap <C-A> <esc>^a
vnoremap <C-A> ^
" nnoremap <C-E> $
inoremap <C-E> <esc>$a
vnoremap <C-E> $

" panes
nnoremap <leader>d <C-w>v <C-w>l
nnoremap <leader>D <C-w>s <C-w>j

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
nnoremap <leader>rcs :source ~/.config/nvim/init.vim<CR>
nnoremap <leader>rce :tabnew ~/.config/nvim/init.vim<CR>
augroup filetype_config
  autocmd!
  autocmd BufNewFile,BufRead *.sh_shared,*.sh_local set filetype=sh
  autocmd FileType vim,nvim,zsh,sh setl sw=2 sts=2 ts=2 et
augroup END


" plugins #####################################################

" FZF
let g:fzf_command_prefix = 'FZF'
nnoremap <C-p> :FZF

" NERDTree
let NERDTreeShowHidden = 1
nnoremap <leader>n :NERDTreeToggle<CR>

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 2
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
if !exists('g:deoplete#omni_patterns')
  let g:deoplete#omni#input_patterns = {}
endif
if !exists('g:deoplete#ignore_sources')
  let g:deoplete#ignore_sources = {}
endif

inoremap <silent><expr> <C-p> deoplete#mappings#manual_complete()
inoremap <silent><expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
inoremap <silent><expr> <C-g> deoplete#undo_completion()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB>
      \ pumvisible() ? "\<C-p>" : "\<S-TAB>"


" language specific settings ##################################

" OCaml
let g:deoplete#omni#input_patterns.ocaml = '[^. *\t]\.\w*|#'
let g:deoplete#ignore_sources.ocaml = ['buffer', 'around']

" ## added by OPAM user-setup for vim / base ## 93ee63e278bdfc07d1139a748ed3fff2 
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
let g:jedi#completions_enabled = 0

" Rust
autocmd FileType rust setl sw=4 sts=4 ts=4 et
let g:racer_cmd = "~/.cargo/bin/racer"
let g:racer_experimental_completer = 1
