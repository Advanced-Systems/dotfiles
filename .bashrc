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
parse_git_branch(){
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

parse_venv(){
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venv="${VIRTUAL_ENV##*/}"
    else
        venv=''
    fi
    [[ -n "$venv" ]] && echo " ($venv) "
}
# +++ end prompt functions

# +++ begin macros
gpip(){
    PIP_REQUIRE_VIRTUALENV=false python -m pip "$@"
}

screenshot(){
    local filename="screenshot.png"
    # screenshot options
    case "$1" in
        window)
            import -window root "$filename"
            ;;
        area)
            import "$filename"
            ;;
        *)
            echo "invalid option"
            ;;
    esac
    # upload to anonfile
    if [[ -f "$filename" ]]; then
        local anon=$(anonfile --verbose upload --file "$filename")
        echo "$anon"
        local url=${anon#"URL: "}
        echo -n "$url" | xclip -selection clipboard
        rm "$filename"
        return 1
    else
        echo "aborting program execution"
        return 0
    fi
}

prompt(){
    [ $(echo -e "No\nYes" | dmenu -i -p "$1") == "Yes" ] && eval "$2"
}

goodbye(){
    prompt "Do you want to turn off your computer?" "shutdown now"
}
# +++ end macros

# custom shortcuts
alias cls=clear
alias ls='ls -g --color=auto'
alias resource='source ~/.bashrc'
alias update='sudo pacman -Syu --noconfirm'

# dotfiles handler
alias config='/usr/bin/git --git-dir=$HOME/documents/repos/dotfiles --work-tree=$HOME'

# custom command prompt
PS1='[$(tput setaf 43)\u$(tput sgr 0)@\h $(tput setaf 41)\W$(tput sgr 0)]'  # [username@hostname]
PS1+='$(tput setaf 184)$(parse_git_branch)$(tput sgr 0)'                    # (branch)
PS1+='$(tput setaf 69)$(parse_venv)$(tput sgr 0)'                           # (venv)
PS1+='\nφ '
export PS1
