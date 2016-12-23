#!/bin/bash

REQUIRE="gcc python"
VIM_PATH="./vim"

# help functions
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    msg "\33[32m ✔ \33[0m ${1}${2}"
}

error() {
    msg "\33[31m ✘ \33[0m ${1}${2}"
    exit 1
}

warn() {
    msg "\33[33m ⚠ \33[0m ${1}${2}"
}

info() {
    msg "\33[32m ➜ \33[0m ${1}${2}"
}

lnif() {
    if [ ! -e $2 ] ; then
        ln -s $1 $2
    fi
}

# check command
for i in $REQUIRE
do
    command -v $i >/dev/null && continue || { error "$i command not found. Please Make sure you have $i installed"; }
done

info "backing up current vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.vim $HOME/.vimrc; do [ -L $i ] && unlink $i ; done
success "Successfully backed up your vim configuration"

info "setting up symlinks"
cp -a $VIM_PATH $HOME/.vim
lnif $HOME/.vim/vimrc $HOME/.vimrc
success "Successfully created symbol links"

info "copy vimrc.bundles.local.example, vimrc.local.example and vimrc.before.example"
cp $HOME/.vim/vimrc.local.example $HOME/.vim/vimrc.local
cp $HOME/.vim/vimrc.bundles.local.example $HOME/.vim/vimrc.bundles.local
cp $HOME/.vim/vimrc.before.example $HOME/.vim/vimrc.before
success "Successfully initialized vim configuration"

# install vim-plug
if [ ! -e $VIM_PATH/autoload/plug.vim ]; then
    info "Installing Vim-Plug"
    curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    success "Successfully installed vim-plug"
fi

info "update/install plugins using vim-plug"
system_shell=$SHELL
export SHELL="/bin/sh"
vim -u $VIM_PATH/vimrc +PlugInstall! +PlugClean +qall
export SHELL=$system_shell

#vim undo dir
if [ ! -d $HOME/.undodir ]
then
    mkdir -p $HOME/.undodir
fi
