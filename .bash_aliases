echo "`printf '\033[01;32m'`Hello `printf '\033[01;34m'`$USER`printf '\033[00m'`"
echo "My IP address is `printf '\033[01;31m'`$(hostname -I)`printf '\033[m'`"

# https://coderwall.com/p/tgm2la
if [[ "$TERM" != "screen" ]] && [[ "$SSH_CONNECTION" == "" ]]; then
    WHOAMI=$(whoami)
    if tmux has-session -t $WHOAMI 2>/dev/null; then
        tmux -2 attach-session -t $WHOAMI
    else
        tmux -2 new-session -s $WHOAMI
    fi
fi

#############
# FUNCTIONS #
#############

# Backup a file with date
function backup() {
    cp "$1" "$1_`date +%Y-%m-%d_%H-%M-%S`_BACKUP"
}

# Extract any archive
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)  tar xjf $1      ;;
            *.tar.gz)   tar xzf $1      ;;
            *.bz2)      bunzip2 $1      ;;
            *.rar)      rar x $1        ;;
            *.gz)       gunzip $1       ;;
            *.tar)      tar xf $1       ;;
            *.tbz2)     tar xjf $1      ;;
            *.tgz)      tar xzf $1      ;;
            *.zip)      unzip $1        ;;
            *.Z)        uncompress $1   ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Ban an IP
function ban() {
    if [ "`id -u`" == "0" ] ; then
        iptables -A INPUT -s $1 -j DROP
    else
        sudo iptables -A INPUT -s $1 -j DROP
    fi
}

# Update + upgrade the system
function maj() {
    sudo aptitude update && sudo aptitude safe-upgrade && sudo aptitude autoclean && sudo aptitude clean
    notify-send -t 10000 "Update and upgrade done"
}

# Display the content of a directory after a 'cd'
function custom_cd () {
        cd $@ && ls
}

# Open a file with the appropriate application
function open {
    while [ "$1" ] ; do
        xdg-open $1 &> /dev/null
        shift # shift décale les param
    done
}

# Remove all backup files in specified directory and sub-directories
function rm_backup {
    find $1 -name '*~' -exec rm '{}' \; -print
}

# A reminder
function findhelp {
    echo "--------------------------------------------------------"
    echo "# Delete a file recursively:"
    echo "find / -name '*.DS_Store' -type f -delete"
    echo "--------------------------------------------------------"
    echo "# Rename a file recursively:"
    echo "find / -type f -exec rename 's/oldname/newname/' '{}' \;"
    echo "--------------------------------------------------------"
    echo "# Find recently modified files"
    echo "find / -type f -printf '%TY-%Tm-%Td %TT %p\n' | sort -r"
    echo "--------------------------------------------------------"
}

# A reminder
function githelp {
    echo "-------------------------------------------------------------------------------"
    echo "git clone http://... [repo-name]"
    echo "git init [repo-name]"
    echo "-------------------------------------------------------------------------------"
    echo "git add -A <==> git add . ; git add -u" # Add to the staging area (index)
    echo "-------------------------------------------------------------------------------"
    echo "git commit -m 'message' -a"
    echo "git commit -m 'message' -a --amend"
    echo "-------------------------------------------------------------------------------"
    echo "git status"
    echo "git log --stat" # Last commits, --stat optional
    echo "git ls-files"
    echo "-------------------------------------------------------------------------------"
    echo "git push origin master"
    echo "git push origin master:master"
    echo "-------------------------------------------------------------------------------"
    echo "git remote add origin http://..."
    echo "git remote set-url origin git://..."
    echo "-------------------------------------------------------------------------------"
    echo "git stash"
    echo "git pull origin master"
    echo "git stash list ; git stash pop"
    echo "-------------------------------------------------------------------------------"
    echo "git submodule add /absolute/path repo-name"
    echo "git submodule add http://... repo-name"
    echo "-------------------------------------------------------------------------------"
    echo "git checkout -b new-branch <==> git branch new-branch ; git checkout new-branch"
    echo "git merge old-branch"
    echo "-------------------------------------------------------------------------------"
    echo "git update-index --assume-unchanged <file>" # Ignore changes
    echo "git rm --cached <file>" # Untrack a file
    echo "-------------------------------------------------------------------------------"
    echo "git reset --hard HEAD" # Repair what has been done since last commit
    echo "git revert HEAD" # Repair last commit
    echo "-------------------------------------------------------------------------------"
}

# A reminder
function tmuxhelp {
    echo "--------------------------------------------------------"
    echo "tmux <=> tmux new -s name"
    echo "--------------------------------------------------------"
    echo "tmux a <=> tmux a -t name # Attach to a session"
    echo "tmux ls ; tmux kill-session -t name # List/kill sessions"
    echo "--------------------------------------------------------"
    echo "# Sessions"
    echo "ctrl+b s # List and change session"
    echo "ctrl+b $ # Rename session"
    echo "ctrl+b d # Detach"
    echo "--------------------------------------------------------"
    echo "# Windows (tabs)"
    echo "ctrl+b c # New window"
    echo "ctrl+b , # Rename window"
    echo "ctrl+b w # List windows"
    echo "ctrl+b f # Find window"
    echo "ctrl+b & # Kill window"
    echo "ctrl+b . # Move window"
    echo "--------------------------------------------------------"
    echo "Panes (splits)"
    echo "ctrl+b % # Horizontal split"
    echo "ctrl+b \" # Vertical split"
    echo "ctrl+b o # Swap panes"
    echo "ctrl+b q # Show pane numbers"
    echo "ctrl+b x # Kill pane"
    echo "ctrl+b (space) # Toggle between layouts"
    echo "ctrl+b (arrow) # Resize panes"
    echo "--------------------------------------------------------"
    echo "# Others"
    ehco "ctrl+b t # Big clock"
    echo "ctrl+b ? # List shortcuts"
    echo "ctrl+b : # Prompt"
    echo "--------------------------------------------------------"
    echo "Taken from: https://gist.github.com/henrik/1967800"
}


###########
# ALIASES #
###########

# Overriding default commands
alias ls='ls --color=auto'
alias grep='grep -i --color=auto'
alias rm='rm --interactive --verbose'
alias mv='mv --interactive --verbose'
alias cp='cp --verbose'
alias cd="custom_cd" # custom_cd is a custom function (see above)

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Handy shortcuts
alias q='exit'
alias lstree="find . | sed 's/[^/]*\//|   /g;s/| *\([^| ]\)/+--- \1/'"
alias path='echo $PATH | tr ":" "\n"'
alias watch='watch ' # Source of this hack: http://yabfog.com/blog/2012/09/06/using-watch-with-a-bash-alias
alias ssh='ssh -X'
alias sshpi="ssh pi@serveur"

# Some sources : 
#  - http://root.abl.es/methods/1504/automatic-unzipuntar-using-correct-tool/
#  - http://forum.ubuntu-fr.org/viewtopic.php?id=20437&p=3
#  - http://www.mercereau.info/partage-de-mon-fichier-bash_aliases/

