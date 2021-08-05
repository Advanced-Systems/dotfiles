#
# (C) 2021 Advanced Systems
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# +++ begin environment variables
export PATH=~/.local/bin:$PATH
export VIRTUAL_ENV_DISABLE_PROMPT=1
export USE_EMOJI=0
# +++ end environment variables

# +++ begin prompt functions
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
# +++ end prompt functions

# +++ begin macros
function gpip(){
    PIP_REQUIRE_VIRTUALENV=false python -m pip "$@"
}
# +++ end macros

# custom shortcuts
alias cls=clear
alias ls='ls -g --color=auto'
alias resource='source ~/.bashrc'
alias goodbye='shutdown now'
alias update='sudo pacman -Syu --noconfirm'

export -f parse_git_branch
export -f parse_venv
export -f gpip

# dotfiles handler
alias config='/usr/bin/git --git-dir=$HOME/documents/repos/dotfiles --work-tree=$HOME'

# custom command prompt
PS1='[$(tput setaf 43)\u$(tput sgr 0)@\h $(tput setaf 41)\W$(tput sgr 0)]'  # [username@hostname]
PS1+='$(tput setaf 184)$(parse_git_branch)$(tput sgr 0)'                    # (branch)
PS1+='$(tput setaf 69)$(parse_venv)$(tput sgr 0)'                           # (venv)
PS1+='\nφ '
export PS1
