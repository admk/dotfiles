" Xitong Gao's Bundles
" Setups {
    " Initialisation {
        set nocompatible
        filetype off
        set runtimepath+=~/.vim/bundle/vundle
        call vundle#rc()
    " }
    " Bundles {
        Bundle 'admk/vim-best-colors'
        Bundle 'davidhalter/jedi-vim'
        Bundle 'bling/vim-airline'
        Bundle 'ehamberg/vim-cute-python'
        Bundle 'admk/vim-isort'
        Bundle 'gmarik/vundle'
        Bundle 'godlygeek/tabular'
        Bundle 'hdima/python-syntax'
        Bundle 'kien/ctrlp.vim'
        Bundle 'mhinz/vim-signify'
        Bundle 'michaeljsmith/vim-indent-object'
        Bundle 'nelstrom/vim-visual-star-search'
        Bundle 'scrooloose/nerdcommenter'
        Bundle 'scrooloose/nerdtree'
        Bundle 'scrooloose/syntastic'
        Bundle 'SirVer/ultisnips'
        Bundle 'sjl/gundo.vim'
        Bundle 'sjl/vitality.vim'
        Bundle 'tpope/vim-abolish'
        Bundle 'tpope/vim-dispatch'
        Bundle 'tpope/vim-fugitive'
        Bundle 'tpope/vim-markdown'
        Bundle 'tpope/vim-repeat'
        Bundle 'tpope/vim-surround'
        Bundle 'tpope/vim-unimpaired'
        Bundle 'Valloric/YouCompleteMe'
        Bundle 'indentpython.vim'
        Bundle 'matchit.zip'
        Bundle 'YankRing.vim'
    " }
    " Finalisation {
        filetype plugin indent on
        let mapleader=","
    " }
" }
" Configurations {
    " Airline {
        let g:airline_theme='pencil'
        let g:airline_left_sep=''
        let g:airline_right_sep=''
        let g:airline_section_b='%{airline#util#wrap(airline#extensions#branch#get_head(),0)}'
        let g:airline_section_y=''
        let g:airline_section_z='%3p%%:%3l'
        let g:airline#extensions#tabline#enabled = 1
        let g:airline#extensions#tabline#show_buffers = 0
        let g:airline#extensions#tabline#tab_min_count = 2
    " }
    " CtrlP {
        nnoremap <leader>cp :CtrlP<cr>
        nnoremap <leader>mr :CtrlPMRUFiles<cr>
    " }
    " yankring {
        nnoremap <leader>yy :YRShow<CR>
        let g:yankring_history_file = '.yankring_history'
    " }
    " NERDTree {
        nnoremap <leader>nt :NERDTreeToggle<cr>
        let NERDTreeIgnore=['\.py[co]$', '\~$', '__pycache__']
    " }
    " SuperTab {
        let g:SuperTabDefaultCompletionType = "context"
        let g:SuperTabLongestEnhanced = 1
        let g:SuperTabLongestHighlight = 1
    " }
    " NerdCommenter {
        let NERDSpaceDelims = 1
        let NERDRemoveExtraSpaces = 1
    " }
    " Syntastic {
        let g:syntastic_error_symbol='X'
        let g:syntastic_warning_symbol='!'
        let g:syntastic_enable_highlighting=0
        let g:syntastic_python_checkers = ['pylint']
    " }
    " Gundo {
        nnoremap <leader>gt :GundoToggle<CR>
    " }
    " Tabularize {
        nnoremap <leader>= :Tabularize /=<CR>
    " }
    " UltiSnips {
        let g:UltiSnipsExpandTrigger = '<c-h>'
        let g:UltiSnipsJumpForwardTrigger = '<c-h>'
        let g:UltiSnipsJumpBackwardTrigger = '<c-l>'
    " }
    " Python Syntax {
        let python_highlight_all = 1
    " }
    " jedi-vim {
        let g:jedi#popup_on_dot = 0
        let g:jedi#popup_select_first = 0
    " }
" }
" vim: set fdm=marker fmr={,}:
