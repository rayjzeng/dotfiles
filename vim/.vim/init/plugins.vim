"
" Plugin configuration
"

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

nmap <F8> :call <SID>ale_toggle()<CR>
nmap <C-n>l <Plug>(ale_lint)
nmap <C-n>r <Plug>(ale_reset_buffer)
nmap <C-n>d <Plug>(ale_detail)
nmap <C-n>a <Plug>(ale_next_wrap)
nmap <C-n>A <Plug>(ale_previous_wrap)

" deoplete
let g:deoplete#enable_smart_case = 1
let g:deoplete#omni#input_patterns = {}
let g:deoplete#ignore_sources = {}

let g:deoplete#enable_at_startup = 0
let g:deoplete#disable_auto_complete = 1

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

nmap <F9> :DeoAutoToggle<CR>
imap <F9> <C-o><F9>
nmap <F10> :DeoToggle<CR>
imap <F10> <C-o><F10>

inoremap <silent><expr> <C-p> deoplete#mappings#manual_complete()
inoremap <silent><expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
inoremap <silent><expr> <C-g> deoplete#undo_completion()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB>
      \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

