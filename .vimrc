if empty(glob('~/.vim/autoload/plug.vim'))
   silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
       \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'qpkorr/vim-bufkill'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-sleuth'
call plug#end()

unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" Status line stuff
set laststatus=2
set noshowmode

" Colours
set t_Co=256
colorscheme desert
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

" Spelling
hi clear SpellBad
hi SpellBad cterm=underline

set expandtab
set backspace=indent,eol,start

" C++
autocmd Filetype cpp setlocal expandtab tabstop=2 shiftwidth=2

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

" Allow switching buffers without saving
set hidden

" Bash like keys for the Vim command line
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>

" Easier buffer switching
:nnoremap <leader>ls :ls<cr>:b<space>

" Replace word under cursor
:nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

" Quickfix shortcuts
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

" vim-go
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)
let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
