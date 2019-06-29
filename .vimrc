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

" Status line stuff
set laststatus=2
set noshowmode

colorscheme desert

" Spelling
hi clear SpellBad
hi SpellBad cterm=underline

set expandtab
set backspace=indent,eol,start

set mouse=

set incsearch
set hlsearch

" Min lines above/below the cursor
set scrolloff=5
set number

" New splits to right and bottom
set splitright
set splitbelow

" Per project .vimrcs
set exrc
set secure

" Compile cmake projects
nnoremap <Leader>mb :make -C build

" Bash like keys for the Vim command line
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>
