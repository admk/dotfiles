" Xitong Gao's vimrc
" Plugins {
    " Pre {
    call plug#begin('~/.vim/plugged')
    let mapleader=","
    " }
    " Cosmetic {
        Plug 'admk/vim-best-colors'
        let g:solarized_visibility="low"
        let g:solarized_menu=0
        let g:solarized_termcolors=256
        Plug 'bling/vim-airline'
        let g:airline_theme='base16'
        let g:airline_left_sep=''
        let g:airline_right_sep=''
        let g:airline_section_b=
            \ '%{airline#util#wrap(airline#extensions#branch#get_head(),0)}'
        let g:airline_section_y=''
        let g:airline_section_z='%3p%%:%3l'
        let g:airline#extensions#tabline#enabled = 1
        let g:airline#extensions#tabline#show_buffers = 0
        let g:airline#extensions#tabline#tab_min_count = 2
        Plug 'ehamberg/vim-cute-python', {'for': 'python'}
    " }
    " Visual {
        Plug 'hdima/python-syntax', {'for': 'python'}
        let python_highlight_all = 1
        Plug 'junegunn/goyo.vim', {'on': 'Goyo'}
        Plug 'mhinz/vim-signify'
    " }
    " Editing {
        Plug 'admk/vim-isort', {'for': 'python'}
        Plug 'godlygeek/tabular', {'on': 'Tabularize'}
        nnoremap <leader>= :Tabularize /=<CR>
        Plug 'honza/vim-snippets'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'scrooloose/nerdcommenter'
        let NERDSpaceDelims = 1
        let NERDRemoveExtraSpaces = 1
        Plug 'SirVer/ultisnips'
        let g:UltiSnipsExpandTrigger = '<c-h>'
        let g:UltiSnipsJumpForwardTrigger = '<c-h>'
        let g:UltiSnipsJumpBackwardTrigger = '<c-l>'
        Plug 'sjl/gundo.vim', {'on': 'GundoToggle'}
        nnoremap <leader>gt :GundoToggle<CR>
        Plug 'tpope/vim-abolish'
        Plug 'tpope/vim-markdown', {'for': 'markdown'}
        Plug 'tpope/vim-repeat'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-unimpaired'
        function! BuildYCM(info)
          " info is a dictionary with 3 fields
          " - name:   name of the plugin
          " - status: 'installed', 'updated', or 'unchanged'
          " - force:  set on PlugInstall! or PlugUpdate!
          if a:info.status == 'installed' || a:info.force
            !./install.sh
          endif
        endfunction
        Plug 'Valloric/YouCompleteMe', {'do': function('BuildYCM')}
        Plug 'indentpython.vim', {'for': 'python'}
        Plug 'YankRing.vim'
        nnoremap <leader>yy :YRShow<CR>
        let g:yankring_history_file = '.yankring_history'
    " }
    " Navigation {
        Plug 'kien/ctrlp.vim'
        let g:ctrlp_map = '<C-T>'
        nnoremap <C-M> :CtrlPMRUFiles<cr>
        Plug 'nelstrom/vim-visual-star-search'
        Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
        nnoremap <leader>nt :NERDTreeToggle<cr>
        let NERDTreeIgnore=['\.py[co]$', '\~$', '__pycache__']
        Plug 'matchit.zip'
    " }
    " Other {
        Plug 'scrooloose/syntastic'
        let g:syntastic_error_symbol='X'
        let g:syntastic_warning_symbol='!'
        let g:syntastic_python_checkers = ['flake8']
        Plug 'sjl/vitality.vim'
        Plug 'tpope/vim-dispatch'
        Plug 'tpope/vim-fugitive'
    " }
    " Post {
    call plug#end()
    " }
" }
" General {
    " File {
        set noswapfile
        set hidden
        set autoread
        set encoding=utf-8
        set termencoding=utf-8
        set fileencoding=utf-8
        autocmd FocusLost * :silent! wall
        autocmd FileType markdown,rst,tex,latex setlocal spell
        autocmd FileType tex,latex
            \ setlocal nocursorline iskeyword+=_
            \ conceallevel=2 foldmethod=manual
        let g:tex_fast=""
        let g:tex_flavor="latex"
        let g:tex_conceal="admgs"
    " }
    " Functional {
        set nocompatible
        set modeline
        set incsearch
        set ignorecase
        set smartcase
        set history=50
        set clipboard=unnamed
        set backspace=indent,eol,start
        set laststatus=2
        set mouse=a
    " }
    " Display {
        syntax on
        set hlsearch
        set showmatch
        set showcmd
        set noshowmode
        set scrolloff=3
        set lazyredraw
        set list
        set listchars=tab:▸\ ,extends:❯,precedes:❮
        augroup trailing_space
            autocmd!
            autocmd InsertEnter * :set listchars-=trail:␣
            autocmd InsertLeave * :set listchars+=trail:␣
        augroup END
        let &showbreak='↳ '
        autocmd VimResized * :wincmd =
    " }
    " Command line {
        set wildchar=<TAB>
        set wildmenu
        set wildmode=list:longest
        set wildignore=*.o,*.pyc,*.pyo
    " }
" }
" Editing {
    " File {
        set undofile
        set backup
        set directory=~/.vim/tmp/swap//
        set undodir=~/.vim/tmp/undo//
        set backupdir=~/.vim/tmp/backup//
        set dictionary=/usr/share/dict/words
        set spellfile=~/.vim/spell/en.utf-8.add
        if !isdirectory(expand(&undodir))
            call mkdir(expand(&undodir), "p")
        endif
        if !isdirectory(expand(&backupdir))
            call mkdir(expand(&backupdir), "p")
        endif
        if !isdirectory(expand(&directory))
            call mkdir(expand(&directory), "p")
        endif
        augroup line_return_on_open
            autocmd!
            autocmd BufReadPost *
                \ if line("'\"") > 0 && line("'\"") <= line("$") |
                \     execute 'normal! g`"zvzz' |
                \ endif
        augroup END
        set virtualedit+=block
    " }
    " Text flow {
        set wrap
        set linebreak
        set textwidth=79
        set formatoptions=rqlmB1
        set formatprg=par\ g\ -w79
    " }
    " Indentation {
        set autoindent
        set smartindent
        set copyindent
        set smarttab
        set expandtab
        set tabstop=4
        set softtabstop=4
        set shiftwidth=4
    " }
    " Folding {
        set foldmethod=syntax
        set foldlevel=1
        set foldnestmax=2
    " }
    " Other {
        set completeopt=menuone,longest,preview
    " }
" }
" User interface {
    " General {
        if has("gui_running")
            set guioptions-=r
            set guioptions-=L
            set guioptions-=T
            set guicursor=n:blinkon0
            set lines=39
            set columns=83
        endif
        if !exists('$SSH_CLIENT')
            set cursorline
            set colorcolumn=+1
        else
            set notimeout
            set ttimeout
            set ttimeoutlen=10
        endif
        " Mac specific
        if has("gui_macvim")
            set macmeta
        endif
        set diffopt+=vertical
    " }
    " Font {
        if has("gui_running")
            let &guifont="M+ 1m light:h16"
            set linespace=-3
        endif
    " }
    " Colorscheme {
        colorscheme base16-ocean
        set background=dark
    " }
" }
" Shortcuts {
    " Essential {
        nnoremap ; :
        vnoremap ; :
        nnoremap j gj
        nnoremap k gk
        nnoremap Y y$
        inoremap jk <ESC>
        inoremap kj <ESC>
        inoremap £ x<BS>#
        inoremap # x<BS>#
    " }
    " General {
        " Search
        noremap / q/i
        noremap ? q?i
        " Leader related
        nnoremap <leader><space> :nohlsearch<CR>
        nnoremap <leader>f :let &fen = !&fen<CR>
    " }
    " Editing {
        " Cursor jumps
        nnoremap ` %
        nnoremap H ^
        nnoremap L $
        " Formatting
        nnoremap Q mzgqip`z
        vnoremap Q gq
        inoremap <C-c> <Esc>[s1z=`]i
        nnoremap <leader>w :%s/\s\+$//<cr>:let @/=''<CR>
    " }
    " Visual mode {
        nnoremap gp `[v`]
        vnoremap < <gv
        vnoremap > >gv
    " }
    " Command line {
        " Sudo
        cnoremap w!! w !sudo tee % >/dev/null
        " Emacs-like
        cnoremap <C-a> <Home>
        cnoremap <C-e> <End>
        cnoremap <C-k> <C-u>
        " Shortcuts
        cnoremap cd. lcd %:p:h
    " }
    " File switching {
        for l in [['h'], ['j'], ['k'], ['l'], ['w'],
                \ ['-'], ['=', '+'], [',', '<'], ['.', '>']]
            if len(l) == 1
                let s:l = l + l
            else
                let s:l = l
            endif
            let s:wincmd = ' :wincmd ' . s:l[1] . '<CR>'
            execute 'nnoremap <M-' . s:l[0] . '>' . s:wincmd
            execute 'nnoremap <Esc>' . s:l[0] . s:wincmd
        endfor
        nnoremap <C-w>t :tabnew<CR>
        nnoremap <M-t> :tabnew<CR>
        nnoremap <Esc>t :tabnew<CR>
        nnoremap gB :bprev<CR>
        nnoremap gb :bnext<CR>
    " }
    " Writing Restructured Text or Markdown {
        noremap <C-u>1 yyPVr#yyjp
        noremap <C-u>2 yyPVr*yyjp
        noremap <C-u>3 yypVr=
        noremap <C-u>4 yypVr-
        noremap <C-u>5 yypVr^
    " }
" }
" Hacks {
    " Highlight {
        highlight! link SignColumn ColorColumn
        highlight! link Conceal Keyword
    " }
" }
" vim: set fdm=marker fmr={,}:
