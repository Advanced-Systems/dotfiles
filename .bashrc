#
# (C) 2021 Advanced Systems
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# +++ begin shell variables
shopt -s histappend
PROMPT_COMMAND='history -a'
HISTSIZE=10000
HISTFILESIZE=10000000
HISTIGNORE='htop:ncdu:ls:mkdir:mkcd:touch:pwd:cd'
HISTCONTROL='ignoreboth:erasedups'
# +++ end shell variables

# +++ begin environment variables
export PATH=~/.local/bin:$PATH
export VIRTUAL_ENV_DISABLE_PROMPT=1
export USE_EMOJI=0
export EDITOR=nvim
export VISUAL=nvim
export LANG=en_US.UTF-8
# +++ end environment variables

# +++ begin macros
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

gpip(){
    PIP_REQUIRE_VIRTUALENV=false python -m pip "$@"
}

screenshot(){
    local filename="screenshot.png"
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
    if [[ -f "$filename" ]]; then
        local anon=$(anonfile --verbose upload --file "$filename")
        echo "$anon"
        local url=${anon#"URL: "}
        echo -n "$url" | xclip -selection clipboard
        rm "$filename"
        return 1
    else
        echo "aborting operation"
        return 0
    fi
}

make(){
    if [[ "$@" == "love" ]]; then
        echo -e "not war?"
    else
        command make "$@"
    fi
}

prompt(){
    [ $(echo -e "No\nYes" | dmenu -i -p "$1") == "Yes" ] && eval "$2" || echo -e "$(tput setaf 184)aight$(tput sgr 0)"
}

goodbye(){
    prompt "Do you want to turn off your computer?" "shutdown now"
}

goodnight(){
    prompt "Do you want to go to sleep?" "systemctl suspend"
}

mkcd(){
    mkdir -p -- "$1" && cd -- "$1"
}

findfile(){
    find . -iname "$@*" 2>&1 | grep -v "permission denied"
}

power(){
    echo -e "$(cat /sys/class/power_supply/BAT0/capacity)%"
}
# +++ end macros

# custom shortcuts
alias cls=clear
alias ls='ls -g --color=auto'
alias resource='source ~/.bashrc'
alias reload='exec $SHELL -l'
alias activate='source ./venv/bin/activate'
alias update='sudo pacman -Syu --noconfirm'
alias count='find . -type f | wc -l'
alias repos='cd -- ~/documents/repos'

# dotfiles handler
alias config='/usr/bin/git --git-dir=$HOME/documents/repos/dotfiles --work-tree=$HOME'

# custom command prompt
PS1='[$(tput setaf 43)\u$(tput sgr 0)@\h $(tput setaf 41)\W$(tput sgr 0)]'  # [username@hostname]
PS1+='$(tput setaf 184)$(parse_git_branch)$(tput sgr 0)'                    # (branch)
PS1+='$(tput setaf 69)$(parse_venv)$(tput sgr 0)'                           # (venv)
PS1+='\nφ '
