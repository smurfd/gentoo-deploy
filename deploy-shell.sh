#!/bin/sh
# Deploy shell configs
# VIM, Tmux & ZSH

SYSTEM=`uname`
OS="none"

# trying to figure out what os you got
if [ "$SYSTEM" == "Linux" ]; then
  if [ -f "/etc/gentoo-release" ]; then
    OS="Gentoo"
  fi
  if [ -f "/etc/SUSE-brand" ]; then
    OS="Suse"
  fi
  if [ -f "/etc/debian_version" ]; then
    OS="Debian" 
  fi
  if [ -f "/etc/redhat-release" ]; then
    OS="Redhat" 
  fi
fi
if [ "$SYSTEM" == "Darwin" ]; then
  OS="Darwin"
fi
if [ "$SYSTEM" == "FreeBSD" ]; then
  OS="FreeBSD"
fi
if [ "$SYSTEM" == "NetBSD" ]; then
  OS="NetBSD"
fi
if [ "$SYSTEM" == "OpenBSD" ]; then
  OS="OpenBSD"
fi

# based on os install zsh, vim and tmux
case $OS in
  "Gentoo")
    sudo emerge -v zsh vim tmux
  ;;
  "Suse")
    sudo zypper in zsh vim tmux
  ;;
  "Debian")
    sudo apt install zsh vim tmux
  ;;
  "Redhat")
    sudo dnf install zsh vim tmux
  ;;
  "Darwin")
    if [ -f "/opt/local/bin/port" ]; then
      sudo port install zsh vim tmux
    else
      brew install zsh vim tmux
  ;;
  "FreeBSD")
    doas pkg install zsh vim tmux
  ;;
  "NetBSD")
    doas pkgin install zsh vim tmux
  ;;
  "OpenBSD")
    doas pkgin install zsh vim tmux
  ;;
esac

# create backups
if [ -f "$HOME/.zshrc" ]; then
  cp $HOME/.zshrc $HOME/.zshrc_before_smurfyfied
fi

if [ -f "$HOME/.vimrc" ]; then
  cp $HOME/.vimrc $HOME/.vimrc_before_smurfyfied
fi

if [ -f "$HOME/.tmux.conf" ]; then
  cp $HOME/.tmux.conf $HOME/.tmux.conf_before_smurfyfied
fi

# create .zsh and .zsh/cache
mkdir -p $HOME/.zsh/cache

# create a .vimrc
cat > $HOME/.vimrc << EOL
" smurfimal vim config 2020701

set background=light
set copyindent
set preserveindent
set nocindent

set expandtab
set tabstop=2
set shiftwidth=2
set conceallevel=1

behave mswin
syntax on

set backspace=2
set notimeout
set ttimeout
set ttimeoutlen=10

set nowrap

set esckeys
set encoding=utf-8 nobomb
set binary

set nobackup
set nowb
set noswapfile
set nowritebackup
set noundofile

set autoread
set showcmd

set showmatch
EOL

# create a .zshrc
cat > $HOME/.zshrc << EOL
local ZSH_CONF=\$HOME/.zsh
local ZSH_CACHE=\$ZSH_CONF/cache

LESSHISTFILE="/dev/null"
HISTFILE=\$ZSH_CACHE/history
SAVEHIST=10000
HISTSIZE=10000
setopt EXTENDED_HISTORY
setopt APPEND_HISTORY 
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS

export PATH=\$HOME/.cargo/bin:\$HOME/.local/bin:\$PATH

if uname | grep -q 'Darwin' ; then
alias ls="ls -pG"
else 
alias ls="ls --color -p"
fi

# start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search # Up

# start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search # Down

# tab completion
autoload -U compinit promptinit
compinit

PROMPT='%B%F{176}%n@%m%f%b {%2~} '
EOL

# create a .tmux.conf
cat > $HOME/.tmux.conf << EOL
# Allow 256 color terminals
set-option -g default-terminal 'xterm-256color'

# Windowlist in the center
set-option -g status-justify centre

# Allowing the left part to be 20 characters
set-option -g status-left-length 20

# Allow the right part to be 140 characters
set-option -g status-right-length 140

# Set the format of the right part of the status bar
set-option -g status-right '#[fg=colour70] %d/%m #[fg=colour60] %H:%M:%S '

# Set the format of the left part of the status bar
set-option -g status-left ' #[fg=colour40]#h '

# set color for status bar
set-option -g status-style bg=colour255,fg=black,dim

# set window title list colors
set-window-option -g window-status-style fg=colour250,bg=colour255

# active window title colors
set-window-option -g window-status-current-style fg=colour200,bg=colour255

# active window format
set-option -g window-status-current-format ' #I#[fg=colour0]:#[fg=colour0]#W#[fg=colour50]#F '

# Ctrl + b + 
# c  create window
# w  list windows
# n  next window
# p  previous window
# f  find window
# ,  name window
# &  kill window
EOL

echo "Zsh, VIM and Tmux installed."
echo "Backed up configs with _before_smurfyfied in suffix"
echo "Configs modified"
echo "Restart the Terminal for changes to take effect"
