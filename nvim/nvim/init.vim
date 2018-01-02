filetype off

"vim-plug configuration {{
call plug#begin('~/.config/nvim/plugged')

Plug 'jeetsukumaran/vim-buffergator'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}

call plug#end()
" }} vim-plug

" general configuration
filetype plugin indent on
au FocusLost * :wa
