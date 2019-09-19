" Modeline and notes {{
" vim: set sw=4 ts=4 sts=4 et foldmarker={{,}} foldlevel=0 foldmethod=marker:
"
" Vim config for Ray Zeng.
" }}

" init {{

    let s:nvim = has('nvim')

    if !s:nvim
        set nocompatible
    endif

    " clear autocmds when hot reloading
    autocmd!

    " set up python environments
    if len(expand($NVIM_PYTHON3)) > 0
        let g:python3_host_prog =expand($NVIM_PYTHON3)
    endif

    if len(expand($NVIM_PYTHON2)) > 0
        let g:python_host_prog=expand($NVIM_PYTHON2)
    endif

    " check python version
    if has('python3')
        py3 import vim; from sys import version_info as v;
                    \ vim.command('let python3_version=%d' % (v[0]*100 + v[1]))
    else
        let python3_version=0
    endif

    " set up shell
    if executable('zsh')
        set shell=/bin/zsh
    else
        set shell=/bin/bash
    endif

" }}

" bundle {{

    call plug#begin('~/.config/nvim/plugged')

    " themes
    Plug 'connorholyday/vim-snazzy'
    Plug 'morhetz/gruvbox'

    " Distraction free mode
    Plug 'junegunn/goyo.vim'

    " Statusline
    Plug 'itchyny/lightline.vim'

    " directory navigator
    Plug 'justinmk/vim-dirvish'

    " Auto intent detection
    Plug 'tpope/vim-sleuth'

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
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'rayjzeng/fzf.vim', { 'branch': 'ray' }

    " ale
    Plug 'w0rp/ale'
    Plug 'maximbaz/lightline-ale'

    Plug 'sheerun/vim-polyglot'

    " ncm2
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc', s:nvim ? {} : { 'on': [] }

    " general completion sourcees
    Plug 'ncm2/ncm2-bufword'
    Plug 'ncm2/ncm2-path'
    Plug 'Shougo/neco-syntax' | Plug 'ncm2/ncm2-syntax'

    " snippets
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'ncm2/ncm2-ultisnips'

    " language server
    Plug 'autozimu/LanguageClient-neovim', {
        \ 'branch': 'next',
        \ 'do': 'bash install.sh',
        \ }

    " vimscript completion
    Plug 'Shougo/neco-vim' | Plug 'ncm2/ncm2-vim'

    call plug#end()

    " merlin and ocp-indent
    let s:opam_share_dir = system("opam config var share")
    let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')
    let s:merlin_dir = s:opam_share_dir . "/merlin/vim"
    if isdirectory(s:merlin_dir)
        execute "set rtp^=" . s:merlin_dir
    endif

    let s:ocp_indent_dir = s:opam_share_dir . "/ocp-indent/vim"
    if isdirectory(s:ocp_indent_dir)
        execute "set rtp^=" . s:ocp_indent_dir
    endif

" }}

" general-config {{

    filetype plugin indent on
    syntax on
    set ttyfast
    set mouse=a
    set hidden

    " use system clipboard by default
    if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
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

    " 24 bit color set when available
    " if $TERM =~# '.*256.*\|kitty' && $COLORTERM ==# 'truecolor'
    "     set termguicolors
    " endif

    " theme
    set background=dark
    let g:gruvbox_contrast_dark="hard"
    let g:gruvbox_contrast_light="medium"
    let g:gruvbox_sign_column="bg0"
    let g:gruvbox_invert_selection=0
    colorscheme gruvbox

    " Line numbering
    set number
    augroup numbering
        autocmd!
        autocmd InsertEnter * set norelativenumber
        autocmd InsertLeave * set relativenumber

        " disable numbering in terminals
        if s:nvim
            autocmd TermOpen * setlocal nonumber norelativenumber
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
    if s:nvim
        " set backup
        if has('persistent_undo')
            set undofile                " So is persistent undo ...
            set undolevels=1000         " Maximum number of changes that can be undone
            set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
        endif
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
        nnoremap g1 1gt
        nnoremap g2 2gt
        nnoremap g3 3gt
        nnoremap g4 4gt
        nnoremap g5 5gt
        nnoremap g6 6gt
        nnoremap g7 7gt
        nnoremap g8 8gt
        nnoremap g9 9gt

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
                    \ :source ~/.config/nvim/init.vim<CR>
        nnoremap <leader><leader>e
                    \ :e ~/.config/nvim/init.vim<CR>

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

" signify {{

    let g:signfiy_vcs_list = [ 'git', 'hg' ]

" }}

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
                    \     'gitbranch': 'fugitive#head',
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

    " ALE {{

        let g:ale_lint_on_text_changed = 'never'
        let g:ale_lint_on_enter = 0
        let g:ale_lint_on_save = 1

        " Linting shortcuts
        nmap <leader>al <Plug>(ale_lint)
        nmap <leader>ar <Plug>(ale_reset_buffer)
        nmap <leader>ad <Plug>(ale_detail)
        nmap <leader>an <Plug>(ale_next_wrap)
        nmap <leader>ap <Plug>(ale_previous_wrap)

    " }}

    " ncm2 {{

        " enable ncm2 for all buffers
        autocmd BufEnter * call ncm2#enable_for_buffer()

        set completeopt=noinsert,menuone,noselect
        " suppress the annoying 'match x of y', 'The only match'
        " and 'Pattern not found' messages
        set shortmess+=c

        " CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
        inoremap <C-c> <ESC>

        " Popup menu settings
        let g:ncm2#auto_popup = 0
        let g:ncm2#popup_limit = 10
        let g:ncm#total_popup_limit = 10
        let g:ncm2#manual_complete_length = [[1,1]]

        " Use CTRL-Space to trigger completion
        inoremap <C-Space> <C-r>=ncm2#manual_trigger()<CR>

        " Use <TAB> to select the popup menu:
        inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

        inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
        inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

    " }}

    " language server registration {{

        let g:LanguageClient_serverCommands = {
            \ 'python': ['pyls'],
            \ }

    " }}

    " ultisnips {{

        inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')
        let g:UltiSnipsExpandTrigger        = "<Plug>(ultisnips_expand)"
        let g:UltiSnipsJumpForwardTrigger   = "<C-j>"
        let g:UltiSnipsJumpBackwardTrigger  = "<C-k>"
        let g:UltiSnipsRemoveSelectModeMappings = 0

    "" }}

    " fzf {{

        let g:fzf_command_prefix = 'F'
        nnoremap s <Nop>

        nnoremap sf :FZF<CR>
        nnoremap sh :FHistory<CR>
        nnoremap sm :FMarks<CR>
        nnoremap sr :FTags<CR>
        nnoremap s: :FHistory:<CR>

        " Search
        nnoremap sg :FRg<Space>
        nnoremap s/ :FBLines<Space>
        nnoremap s? :FLines<Space>

        " Buffers
        nnoremap ss :FBuffers<CR>
        nnoremap S :FWindows<CR>

    " }}

" }}

