#
# (C) 2021 Advanced Systems
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# functions
function parse_git_branch(){
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

function parse_venv(){
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venv="${VIRTUAL_ENV##*/}"
    else
        venv=''
    fi
    [[ -n "$venv" ]] && echo " ($venv) "
}

# custom shortcuts
alias cls=clear
alias ls='ls -g --color=auto'
alias resource='source ~/.bashrc'
alias update='sudo pacman -Syu --noconfirm'
export -f parse_git_branch
export -f parse_venv
export VIRTUAL_ENV_DISABLE_PROMPT=1

# dotfiles handler
alias config='/usr/bin/git --git-dir=$HOME/documents/repos/dotfiles --work-tree=$HOME'

# command prompt
PS1='[$(tput setaf 43)\u$(tput sgr 0)@\h $(tput setaf 41)\W$(tput sgr 0)]'  # [username@hostname]
PS1+='$(tput setaf 184)$(parse_git_branch)$(tput sgr 0)'                    # (branch)
PS1+='$(tput setaf 69)$(parse_venv)$(tput sgr 0)'                           # (venv)
PS1+='\nφ '
export PS1
