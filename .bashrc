#
# (C) 2021 Advanced Systems
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# auto-start the ssh agent
eval $(ssh-agent) > /dev/null 2>&1

# +++ begin shell variables
shopt -s histappend
PROMPT_COMMAND='history -a'
HISTSIZE=10000
HISTFILESIZE=10000000
HISTIGNORE='htop:ncdu:ls:mkdir:mkcd:touch:pwd:cd'
HISTCONTROL='ignoreboth:erasedups'
# +++ end shell variables

# +++ begin environment variables
export REPOS=$HOME/documents/repos
export PATH=~/.local/bin:$PATH
export VIRTUAL_ENV_DISABLE_PROMPT=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export GIT_EDITOR=nvim
export USE_EMOJI=0
export EDITOR=nvim
export VISUAL=nvim
export LANG=en_US.UTF-8
# +++ end environment variables

# +++ begin macros
_dotnet_bash_complete(){
  local word=${COMP_WORDS[COMP_CWORD]}

  local completions
  completions="$(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)"
  if [ $? -ne 0 ]; then
    completions=""
  fi

  COMPREPLY=( $(compgen -W "$completions" -- "$word") )
}

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

pip(){
    if [[ "$@" == "upgrade-all" ]]; then
        for pkg in $(python -m pip freeze)
        do
            local name=$(echo -e $pkg | cut -f1 -d '=')
            if [ ! $name = "git*" ]; then
                python -m pip install --upgrade $pkg
            fi
        done
    else
        command pip "$@"
    fi
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

grepo-all(){
    local username=$(git config --global user.name)
    local response=$(curl --silent --show-error -X GET "https://api.github.com/users/$username/repos")
    mkdir -p $REPOS
    for full_name in $(echo $response | jq '.[]' | jq '.full_name' | tr -d '"')
    do
        (cd $REPOS && git clone "git@github.com:$full_name.git")
    done
}

pacman-build(){
    mkdir -p $REPOS/$1
    git clone https://aur.archlinux.org/"$1".git $REPOS/$1
    (cd $REPOS/$1 && makepkg --syncdeps --clean --install --needed --noconfirm)
    sudo pacman -U $REPOS/$1/*.pkg.tar.zst --noconfirm
}

export-icon(){
    local size=1024
    while (( size >= 16 ))
    do
        inkscape $1 -w $size -h $size -o "${1%.[^.]*}-${size}x${size}.png"
        size=$(( $size / 2 ))
    done
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

lss(){
    du -h --max-depth=1 -- $1 | sort -hr
}

count(){
    find $1 -type d | wc -l
}
# +++ end macros

# +++ start aliases
alias cls=clear
alias ls='ls -g --color=auto'
alias resource='source ~/.bashrc'
alias reload='exec $SHELL -l'
alias activate='source ./venv/bin/activate'
alias update='sudo pacman -Syu --noconfirm'
alias repos='cd -- $REPOS'
alias config='/usr/bin/git --git-dir=$REPOS/dotfiles --work-tree=$HOME'
# +++ end aliases

# +++ start misc settings
PS1='[$(tput setaf 43)\u$(tput sgr 0)@\h $(tput setaf 41)\W$(tput sgr 0)]'  # [username@hostname]
PS1+='$(tput setaf 184)$(parse_git_branch)$(tput sgr 0)'                    # (branch)
PS1+='$(tput setaf 69)$(parse_venv)$(tput sgr 0)'                           # (venv)
PS1+='\nφ '

complete -f -F _dotnet_bash_complete dotnet
# +++ end misc settings
