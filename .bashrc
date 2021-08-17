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

extract(){
    if [[ -f "$1" ]]; then
        case "$1" in
            *.zip)
                python -m zipfile -e "$1" .
                ;;
            *.rar)
                7z x "$1"
                ;;
            *.7z)
                7z x "$1"
                ;;
            *.tar)
                tar xfv "$1"
                ;;
            *.tar.gz)
                tar xzfv "$1"
                ;;
            *.tar.bz2)
                tar xjfv "$1"
                ;;
            *.tar.xz)
                tar xJv "$1"
                ;;
            *.tar.zst)
                unzstd -v "$1"
                ;;
            *)
                echo -e "$(tput setaf 196)cannot extract '$1': unknown file extension$(tput sgr 0)"
                ;;
        esac
    else
        echo -e "$(tput setaf 196)cannot extract '$1': not a file$(tput sgr 0)"
    fi
}

make(){
    if [[ "$@" == "love" ]]; then
        echo -e "not war?"
    else
        command make "$@"
    fi
}

grepo(){
    git clone git@github.com:$(git config --global user.name)/"$1".git
}

mk-ssh-key(){
    echo -n "Do you want to use your email address that is stored in your global git settings? [Y/n]: "
    read answer
    local mail="n/a"


    if [[ "$answer" == [Yy] || "$answer" == "" ]]; then
        mail=$(git config --global user.email)
    else
        read -p "Enter an email address: " mail
    fi

    read -p "Enter a name for the public key file: " pkeyname
    read -s -p "Enter a passphrase: " passphrase

    # don't overwrite ~/.ssh/id_rsa if it already exists
    cat /dev/zero | ssh-keygen -t rsa -b 4096 -C $mail -f ~/.ssh/$pkeyname -q -N $passphrase
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/$pkeyname
    cat ~/.ssh/$pkeyname.pub | xclip -selectio clipboard

    echo -e "$(tput setaf 184)Copied the public key to clipboard$(tput sgr 0)"
    return 0
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
alias lss='du -h --max-depth=1 -- * | sort -hr'
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
