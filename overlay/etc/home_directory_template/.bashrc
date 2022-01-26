#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Export user's home directory bin directories
PATH=$PATH:$HOME/.local/bin:$HOME/bin
# Export /usr/games
PATH=$PATH:/usr/games
# Export flatpak data directories
XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/${USER}/.local/share/flatpak/exports/share"
