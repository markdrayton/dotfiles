if empty(glob('~/.vim/autoload/plug.vim'))
   silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
       \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
call plug#end()

unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" status line stuff
set laststatus=2
set noshowmode

colorscheme desert
hi clear SpellBad
hi SpellBad cterm=underline

set expandtab
set backspace=indent,eol,start

set mouse=

set incsearch
set hlsearch

set number

" per project .vimrcs
set exrc
set secure

" Min lines above/below the cursor
set scrolloff=5

nnoremap <Leader>m :make -C build
