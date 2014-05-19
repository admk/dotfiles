#!/bin/sh

VIM="$HOME/.ko-vim"

echo "Backing up your Vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc; do
    [ -e $i ] && [ ! -L $i ] && mv $i $i.$today
done

echo 'Initialising Vim config'
if [ ! -e $VIM/.git ]; then
    git clone -b master https://github.com/admk/ko-vim.git $VIM
else
    cd $VIM
    git pull
fi

echo 'Linking'
cd $HOME
ln -sf $VIM $HOME/.vim
ln -sf $VIM/vimrc $HOME/.vimrc

echo 'Initialising Vundle'
git clone http://github.com/gmarik/vundle.git $VIM/bundle/vundle

echo 'Installing all bundles'
vim -u $VIM/bundles.vim +BundleInstall! +BundleClean +qall
