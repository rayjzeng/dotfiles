" vim: set sw=4 ts=4 sts=4 et fmr={{,}} fdm=marker:
" Vim config for Ray Zeng.

" clear autocmds when hot reloading
autocmd!

" pre init
if filereadable(expand('$HOME/.vimrc.before.vim'))
    exe 'source ~/.vimrc.before.vim'
endif

" init {{

    set nocompatible

    let s:nvim = has('nvim')
    if s:nvim
        let s:plugdir = '~/.config/nvim/plugged'
    else
        let s:plugdir = '~/.vim/plugged'
    endif

    " set up shell
    if executable('zsh')
        set shell=/bin/zsh
    else
        set shell=/bin/bash
    endif

" }}

" bundle {{

    call plug#begin(s:plugdir)

    " tmux integration
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'rayjzeng/vim-tmux-clipboard'
    Plug 'tmux-plugins/vim-tmux-focus-events'

    " themes
    Plug 'gruvbox-community/gruvbox'

    " Statusline
    Plug 'itchyny/lightline.vim'

    " directory navigator
    Plug 'justinmk/vim-dirvish'

    " Movement
    Plug 'unblevable/quick-scope'

    " Text manipulation
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-repeat'

    " Git integration
    Plug 'tpope/vim-fugitive'
    Plug 'mhinz/vim-signify'

    " fzf
    Plug 'junegunn/fzf'
    Plug '~/.vim/fzf.vim'

    " syntax
    Plug 'sheerun/vim-polyglot'

    " Auto intent detection
    Plug 'tpope/vim-sleuth'

    call plug#end()

" }}

" general-config {{

    filetype plugin indent on
    syntax enable
    set ttyfast
    set mouse=a
    set hidden

    " use system clipboard by default
    if has('clipboard')
        if has('unnamedplus')  " use + register on x11 systems
            set clipboard+=unnamed,unnamedplus
        else
            set clipboard+=unnamed
        endif
    endif

" }}

" visual config {{

    set showcmd                     " show last command
    set laststatus=2                " always show status line
    set wildmenu                    " enhanced command line

    set winminheight=0              " Windows can be 0 line high
    set scrolloff=1                 " min lines above/below cursor
    set sidescrolloff=1             " min columns left/right cursor

    set colorcolumn=80              " visual ruler
    set cursorline                  " highlight cursor line

    set splitright                  " open splits to right
    set splitbelow                  " open splits to bottom

    " Cursor settings for Vim
    "  1 -> blinking block
    "  2 -> solid block
    "  3 -> blinking underscore
    "  4 -> solid underscore
    "  5 -> blinking vertical bar
    "  6 -> solid vertical bar

    let &t_SI.="\<esc>[5 q" "SI = INSERT mode
    let &t_SR.="\<esc>[4 q" "SR = REPLACE mode
    let &t_EI.="\<esc>[2 q" "EI = NORMAL mode (ELSE)

    set ttimeout
    set ttimeoutlen=10  " reduce timeout for keycodes

    " 24 bit color set when available
    if $TERM =~# '.*256color.*' || $COLORTERM ==# 'truecolor'
        " set Vim-specific sequences for RGB colors
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        set termguicolors
    endif

    if $TERM =~ 'xterm'
        let &t_ti = "\<Esc>[?47h"
        let &t_te = "\<Esc>[?47l"
    endif

    " theme
    set background=dark
    let g:gruvbox_contrast_dark="hard"
    let g:gruvbox_contrast_light="medium"
    let g:gruvbox_sign_column="bg0"
    let g:gruvbox_invert_selection=0
    colorscheme gruvbox

    " Line numbering
    set number
    set relativenumber
    augroup numbering
        autocmd! numbering
        autocmd InsertEnter * setlocal norelativenumber
        autocmd InsertLeave * setlocal relativenumber

        " disable numbering in terminals
        if s:nvim
            autocmd TermOpen * setlocal nonumber norelativenumber
        else
            autocmd TerminalOpen * setlocal nonumber norelativenumber nolist
        endif
    augroup END

    " search
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    let @/ = ""                     " clear last search when sourcing this file

    " show previews for search and replace
    if s:nvim
        set inccommand=nosplit
    endif

    " Whitespace charaters
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" }}

" editing {{

    " Sane backspace behavior
    set backspace=indent,eol,start

    " Line wrapping
    set nowrap
    set formatoptions=jtcroql

    " Indentation
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " (sw) Use indents of 4 spaces
    set noexpandtab                 " (et) Use tabs by default
    set tabstop=4                   " (ts) An indentation every four columns
    set softtabstop=4               " (sts) Let backspace delete indent

    " toggle for paste mode
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)

    if &history < 10000
        set history=10000
    endif

    " set undo and backup when using neovim
    if has('persistent_undo')
        if !s:nvim
            call mkdir($HOME.'/.local/share/vim/undo', 'p')
            set undodir=$HOME/.local/share/vim/undo
        endif
        set undofile                " So is persistent undo ...
        set undolevels=1000         " Maximum number of changes that can be undone
        set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
    endif

" }}

" remappings {{

    " note <C-/> is mapped as <C-_>

    " General keyboard remappings
    let mapleader = ' '
    inoremap jk <ESC>
    nnoremap Q @@

    " window management shortcuts {{

        " create splits
        nnoremap <leader>v <C-w>v <C-w>l
        nnoremap <leader>V :botright vsplit<CR> <C-w>j
        nnoremap <leader>x <C-w>s <C-w>j
        nnoremap <leader>X :botright split<CR> <C-w>j

        nnoremap <leader>= <C-w>=

        " quick navigation
        nnoremap <C-J> <C-W>j
        nnoremap <C-K> <C-W>k
        nnoremap <C-L> <C-W>l
        nnoremap <C-H> <C-W>h
        nnoremap <C-Q> <C-W>q

        " Easy buffer switching
        nnoremap gb :bn<CR>
        nnoremap gB :bp<CR>
        nnoremap gw :bd<CR>

        " Jump to tab number
        nnoremap <leader>1 1gt
        nnoremap <leader>2 2gt
        nnoremap <leader>3 3gt
        nnoremap <leader>4 4gt
        nnoremap <leader>5 5gt
        nnoremap <leader>6 6gt
        nnoremap <leader>7 7gt
        nnoremap <leader>8 8gt
        nnoremap <leader>9 :tabl<CR>

    " }}

    " text editing shortcuts {{

        " Emacs like start/end of line in insert/visual mode
        inoremap <C-A> <C-o>I
        vnoremap <C-A> ^
        inoremap <C-E> <C-o>A
        vnoremap <C-E> $

        " Default search to very magic (full regex)
        nnoremap / /\v
        vnoremap / /\v

        " clear highlight
        nnoremap <silent> <leader>n :noh<CR>

        " Use magic for substitution
        nnoremap \ :%s/\v
        vnoremap \ :s/\v

        " Yank from the cursor to the end of the line, to be consistent with C and D.
        nnoremap Y y$

        " Visual shifting (does not exit Visual mode)
        vnoremap < <gv
        vnoremap > >gv

        " Allow using the repeat operator with a visual selection (!)
        " http://stackoverflow.com/a/8064607/127816
        vnoremap . :normal .<CR>

    " }}

    " utility shortcuts {{

        fun! s:TrimWhitespace()
            let l:save = winsaveview()
            keeppatterns %s/\s\+$//e
            call winrestview(l:save)
        endfun

        " strip whitespace at eol
        command! TrimWhitespace call s:TrimWhitespace()
        nnoremap <leader>w :TrimWhitespace<CR>

        " retab
        nnoremap <leader>r :retab<CR>

        " Open current buffer as root
        cnoremap w!! w !sudo tee % >/dev/null

        " Change Working Directory to that of the current file
        cmap cwd lcd %:p:h

        " command-line editing
        cnoremap <C-A> <Home>

        tnoremap <C-[> <C-\><C-n>

    " }}

    " config editing {{

        nnoremap <leader><leader>s
                    \ :source ~/.vimrc<CR>
        nnoremap <leader><leader>e
                    \ :e ~/.vimrc<CR>

        " config filetypes
        augroup config_ft
            autocmd!
            autocmd BufNewFile,BufRead zim, zimrc, zprofile set filetype=zsh
            autocmd FileType zsh,sh setl sw=2 sts=2 ts=2 et
            autocmd FileType vim setl sw=4 sts=4 ts=4 et
        augroup END

    " }}

" }}

" plugin-config {{

    " lightline {{

        let g:lightline = {
                    \ 'colorscheme': 'gruvbox',
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
                    \     'gitbranch': 'FugitiveHead',
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

    " }}

    " fzf {{

        let g:fzf_command_prefix = 'F'
        nnoremap s <Nop>

        nnoremap sf :FFiles<CR>
        nnoremap sh :FHistory<CR>
        nnoremap sm :FMarks<CR>
        nnoremap st :FTags<CR>
        nnoremap s: :FHistory:<CR>

        " Search
        nnoremap sg :FRg<Space>
        nnoremap s/ :FBLines<Space>
        nnoremap s? :FLines<Space>

        " Buffers
        let g:fzf_buffers_jump = 1  " jump to existing tabs
        nnoremap ss :FBuffers<CR>
        nnoremap S :FWindows<CR>

    " }}

" }}

" post init
if filereadable(expand('$HOME/.vimrc.after.vim'))
    exe 'source ~/.vimrc.after.vim'
endif

