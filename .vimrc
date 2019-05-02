unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

colorscheme desert
hi clear SpellBad
hi SpellBad cterm=underline

set expandtab nu
set backspace=indent,eol,start

set mouse=

set incsearch
set hlsearch

" Min lines above/below the cursor
set scrolloff=5
