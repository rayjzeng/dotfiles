" Modeline and notes {{
" vim: set sw=4 ts=4 sts=4 et foldmarker={{,}} foldlevel=0 foldmethod=marker:
"
" Vim config for Ray Zeng.
" }}

" init {{

    let s:has_nvim = has('nvim')

    if has('python3')
        py3 import vim; from sys import version_info as v;
                    \ vim.command('let python3_version=%d' % (v[0]*100 + v[1]))
    else
        let python3_version=0
    endif

    if !s:has_nvim
        set nocompatible
    endif

    " clear autocmds when hot reloading
    autocmd!

    if executable('zsh')
        set shell=/bin/zsh
    else
        set shell=/bin/bash
    endif

    " Set python based on environment variables
    if len(expand($NVIM_PYTHON2)) > 0
        let g:python_host_prog=expand($NVIM_PYTHON2)
    endif
    if len(expand($NVIM_PYTHON3)) > 0
        let g:python3_host_prog =expand($NVIM_PYTHON3)
    endif

" }}

" bundle {{

    call plug#begin('~/.config/nvim/plugged')

    " ui elements {{

        " Onedark theme
        Plug 'joshdick/onedark.vim'

        " Distraction free mode
        Plug 'junegunn/goyo.vim'

        " Statusline
        Plug 'itchyny/lightline.vim'

        " directory navigator
        Plug 'justinmk/vim-dirvish'

    " }}

    " text editing {{

        " Auto intent detection
        Plug 'tpope/vim-sleuth'

        " Movement
        Plug 'justinmk/vim-sneak'
        Plug 'unblevable/quick-scope'

        " Better find/replace
        Plug 'osyo-manga/vim-over'

        " Text manipulation
        Plug 'Raimondi/delimitMate'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-commentary'

    " }}

    " integrations {{

        " Git integration
        Plug 'tpope/vim-fugitive'
        Plug 'mhinz/vim-signify'

        " fzf
        Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
        Plug 'rayjzeng/fzf.vim', { 'branch': 'ray' }

        " Linting and Completion
        Plug 'w0rp/ale'
        Plug 'maximbaz/lightline-ale'

        " better autocomplete for neovim
        if s:has_nvim
            Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
        else
          Plug 'Shougo/deoplete.nvim'
          Plug 'roxma/nvim-yarp'
          Plug 'roxma/vim-hug-neovim-rpc'
        endif

    " }}

    " Language plugins {{

        " OCaml
        Plug 'copy/deoplete-ocaml'
        Plug 'rgrinberg/vim-ocaml'

        " Python
        Plug 'zchee/deoplete-jedi'

        " Javascript
        Plug 'pangloss/vim-javascript'

    " }}

    call plug#end()

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

    set colorcolumn=80              " visual ruler
    set cursorline                  " highlight cursor line

    set splitright                  " open splits to right
    set splitbelow                  " open splits to bottom

    " 24 bit color set when available
    if $TERM =~# '.*256.*\|kitty' && $COLORTERM ==# 'truecolor'
        set termguicolors
    endif

    " theme
    let g:onedark_termcolors=16
    colorscheme onedark

    " Line numbering
    set number
    augroup numbering
        autocmd!
        autocmd InsertEnter * set norelativenumber
        autocmd InsertLeave * set relativenumber

        " disable numbering in terminals
        if s:has_nvim
            autocmd TermOpen * setlocal nonumber norelativenumber
        endif
    augroup END

    " search
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present

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
    if s:has_nvim
        " set backup
        if has('persistent_undo')
            set undofile                " So is persistent undo ...
            set undolevels=1000         " Maximum number of changes that can be undone
            set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
        endif
    endif

" }}

" remappings {{

    " General keyboard remappings
    let mapleader = ' '
    inoremap jk <ESC>
    nnoremap Q @@

    " window management shortcuts {{

        " create splits
        nnoremap <leader>v <C-w>v <C-w>l
        nnoremap <leader>V :botright vsplit<CR> <C-w>j
        nnoremap <leader>s <C-w>s <C-w>j
        nnoremap <leader>S :botright split<CR> <C-w>j

        nnoremap <leader>= <C-w>=

        " quick navigation
        nnoremap <C-J> <C-W><C-J>
        nnoremap <C-K> <C-W><C-K>
        nnoremap <C-L> <C-W><C-L>
        nnoremap <C-H> <C-W><C-H>

        " Easy buffer switching
        nnoremap <silent> gb :bn<CR>
        nnoremap <silent> gB :bp<CR>

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

        " use vim-over for replace
        nnoremap \ :OverCommandLine<CR>%s/
        vnoremap \ :OverCommandLine<CR>s/

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

        " strip whitespace at eol
        nnoremap <silent> <leader><leader>rtw :%s/\s\+$//e<CR>

        " Open current buffer as root
        cnoremap w!! w !sudo tee % >/dev/null

        " Change Working Directory to that of the current file
        cmap cwd lcd %:p:h
        cmap cd. lcd %:p:h

    " }}

    " config editing {{

        nnoremap <silent> <leader><leader>s
                    \ :source ~/.config/nvim/init.vim<CR>
        nnoremap <silent> <leader><leader>e
                    \ :e ~/.config/nvim/init.vim<CR>

        " config filetypes
        augroup config_ft
            autocmd!
            autocmd BufNewFile,BufRead *.sh_shared,*.sh_local set filetype=sh
            autocmd BufNewFile,BufRead zprofile,zpreztorc set filetype=zsh
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

    " }}

    " deoplete {{
    if (python3_version >= 306)

        " Enable deoplete
        let s:deo_enabled = 1
        let g:deoplete#enable_at_startup = s:deo_enabled

        " Set options
        call deoplete#custom#option('smart_case', 1)

        " Enable autocompletion popup
        let s:auto_enabled = 1
        call deoplete#custom#option('auto_complete', s:auto_enabled)

        " Toggle deoplete
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
        nnoremap <silent> <F2> :DeoToggle<CR>

        " Toggle auto complete
        function! s:deo_auto_toggle()
            if s:auto_enabled
                echo 'Disabling tab complete.'
            else
                echo 'Enabling tab complete.'
            endif
            let s:auto_enabled = !s:auto_enabled
            call deoplete#custom#option({ 'auto_complete': s:auto_enabled })
        endfunction
        command! DeoAuto call s:deo_auto_toggle()
        nnoremap <silent> <F3> :DeoAuto<CR>

        " Completion keybindings
        inoremap <silent><expr> <C-p> deoplete#mappings#manual_complete()
        inoremap <silent><expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
        inoremap <silent><expr> <C-g> deoplete#undo_completion()
        inoremap <silent><expr> <TAB>
                    \ pumvisible() ? "\<C-n>" : "\<TAB>"
        inoremap <silent><expr> <S-TAB>
                    \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

        " Omni source config for languages
        call deoplete#custom#option('ignore_sources',
                    \ {
                    \   'ocaml': ['buffer', 'around', 'member', 'tag'],
                    \ })

        " custom sources
        call deoplete#custom#source('jedi', 'show_docstring', 1)

    endif
    " }}

    " fzf {{

        let g:fzf_command_prefix = 'F'

        " Find files in cwd
        nnoremap <C-p> :FZF<CR>

        " Find lines in open buffers (note <C-/> is mapped to <C-_>)
        nnoremap <C-_> :FLines<CR>

        " Buffers
        nnoremap <leader>b :FBuffers<CR>

        " Tabs
        nnoremap <leader>t :FWindows<CR>

        " Marks
        nnoremap <leader>m :FMarks<CR>

        " History
        nnoremap <leader>h :FHistory<CR>

        nnoremap q: :FHistory:<CR>

        nnoremap q/ :FHistory/<CR>

    " }}

    " sneak {{
        let g:sneak#label = 1
    " }}

" }}

" lang-config {{

    " OCaml
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

    autocmd FileType ocaml call <SID>OCamlConf()


    " Python
    autocmd FileType python setl sw=4 sts=4 ts=4 et


    " Javascript
    autocmd FileType javascript setl sw=4 sts=4 ts=4 et


    " HTML
    autocmd FileType html setl sw=2 sts=2 ts=2 et

" }}
