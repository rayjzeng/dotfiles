"
" Filetype specific settings
" 

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

autocmd FileType ocaml call OCamlConf()

" Python
autocmd FileType python setl sw=4 sts=4 ts=4 et
let g:jedi#completions_enabled = 0

" Rust
autocmd FileType rust setl sw=4 sts=4 ts=4 et
let g:racer_cmd = "~/.cargo/bin/racer"
let g:racer_experimental_completer = 1
