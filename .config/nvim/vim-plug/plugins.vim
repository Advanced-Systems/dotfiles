" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
	silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall
	autocmd VimEnter * PLugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')
	" improved syntax support
	Plug 'sheerun/vim-polyglot'
	" file explorer
	Plug 'scrooloose/NERDTree'
	" auto-pairs '(', '[', '{'
	Plug 'jiangmiao/auto-pairs'
call plug#end()
