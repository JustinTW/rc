# Path to your oh-my-zsh configuration.
ZSH=$HOME/.rc/oh-my-zsh

# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="blinks-venv"
ZSH_THEME="dst"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git python screen ssh-agent autojump coffee git-flow git-remote-branch tmux vagrant debian cp command-not-found last-working-dir docker)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:$HOME/.rvm/bin

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# vi key binding
bindkey '^R' history-incremental-search-backward
export EDITOR=vim

source $ZSH/plugins/history-substring-search/history-substring-search.zsh
bindkey '^[OA' history-substring-search-up

# HISTORY
# number of lines kept in history
export HISTSIZE=10000
# # number of lines saved in the history after logout
export SAVEHIST=10000
# # location of history
export HISTFILE=~/.zhistory
# # append command to history file once executed
setopt APPEND_HISTORY

setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt inc_append_history
setopt no_hist_allow_clobber
setopt no_hist_beep
setopt inc_append_history share_history

# virtualenv and virtualenvwrapper
if [ -f "/usr/local/bin/virtualenvwrapper.sh" ]
then
    VIRTUALENVWRAPPER_PYTHON='/usr/bin/python3'
    source /usr/local/bin/virtualenvwrapper.sh > /dev/null 2>&1
    export VIRTUAL_ENV_DISABLE_PROMPT='1'
    export WORKON_HOME=~/Envs
fi

# alias
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

alias -g gbp='git-buildpackage'

## Del
# Delete key (see FreeBSD FAQ on keyboard and mouse)
bindkey "\e[3~"   delete-char              # xterm

## Home & End
# Home and End keys for XTerm compatible console
bindkey "\e[1~"   beginning-of-line        # xterm
bindkey "\e[4~"   end-of-line              # xterm
bindkey "^[OH" beginning-of-line           # zsh
bindkey "^[OF" end-of-line                 # zsh

# histroy-forward for down keys
[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-beginning-search-backward
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-beginning-search-forward

# git
alias g='git'
alias ga='git add'
alias gs='git status'
alias gc='git commit'
alias gco='git checkout'
alias gcm='git commit -m'
alias gp='git pull && push'
alias gb='git branch -a'
alias gpl='git stash && git pull && git stash pop'

alias gd='git diff'
alias gdc='git diff --cached'
alias gdh='git diff HEAD'

alias gst='git status -s -b'
alias gl='git log'

export LC_ALL=C

alias rgl='rvm gemset list'
alias rgc='rvm gemset create'
alias rge='rvm gemset empty'
alias rgu='rvm gemset use'
alias rgd='rvm gemset delete'

alias cw='cd ~/workspace'

alias vgs='vagrant ssh'
alias vgu='vagrant up'
#alias vgus='vagrant up $1 && vagrant ssh $1'
alias vgh='vagrant halt'
#alias vgr='vagrant halt $1 && vagrant up $1'
alias vgd='vagrant destroy -f'
#alias vgdr='vagrant destroy -f $1 && vagrant up $1'
alias vgp='vagrant provision'

# psql
export PSQL_EDITOR='vim +"set syntax=sql"'
export YELLOW=`echo -e '\033[1;33m'`
export LIGHT_CYAN=`echo -e '\033[1;36m'`
export NOCOLOR=`echo -e '\033[0m'`

export LESS="-iMSx4 -FXR"

PAGER="sed \"s/\([[:space:]]\+-[0-9.]\+\)$/${LIGHT_CYAN}\1$NOCOLOR/;"
PAGER+="s/\([[:space:]]\+[0-9.\-]\+[[:space:]]\)/${LIGHT_CYAN}\1$NOCOLOR/g;"
PAGER+="s/|/$YELLOW|$NOCOLOR/g;s/^\([-+]\+\)/$YELLOW\1$NOCOLOR/\" 2>/dev/null  | less"
export PAGER

# FASD https://github.com/clvv/fasd
export PATH=$PATH:$HOME/.rc/fasd
eval "$(fasd --init auto)"

alias v='f -e vim' # quick opening files with vim

alias stt='subl .'

function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function vgus(){
vagrant up $1 && vagrant ssh $1
return
}

function vgrs(){
vagrant halt $1 && vagrant up $1 && vagrant ssh $1
return
}

function vgr(){
vagrant halt $1 && vagrant up $1 && vagrant ssh $1
return
}

function vgdr(){
vagrant destroy -f $1 && vagrant up $1 && vagrant ssh $1
return
}

function t(){
terminator -l $1 2>/dev/null &
return
}

function sss(){
SSHUSER="hopebayadmin"
SSPASSWORD="SSPASSWORD"
ssh-keygen -f "/home/robo/.ssh/known_hosts" -R $1 || true
sshpass -p "$SSPASSWORD" ssh-copy-id -o StrictHostKeyChecking=no $SSHUSER@$1 2>/dev/null && \
ssh $SSHUSER@$1 -t "sudo -u root sed -i -e 's/%sudo	ALL=(ALL:ALL) ALL/%sudo	ALL=NOPASSWD:ALL/g' /etc/sudoers" && \
ssh $SSHUSER@$1 -t sudo tmux
}

function bsn(){
if [ ! -z "$1" ]; then
sudo btrfs subvolume snapshot /mnt/btrfs/@home /mnt/btrfs/@home-`date "+%Y-%m%d-%H%M"`-$1
sudo btrfs subvolume snapshot /mnt/btrfs/@root /mnt/btrfs/@root-`date "+%Y-%m%d-%H%M"`-$1
else
echo "Please input name, eg: bsn init-snapshot"
fi
sudo btrfs subvolume list /mnt/btrfs
}

function bsnd(){
if [ ! -z "$1" ]; then
sudo btrfs subvolume delete /mnt/btrfs/@home-$1
sudo btrfs subvolume delete /mnt/btrfs/@root-$1
else
echo "Please input name for delete, eg: bsnd init-snapshot"
fi
sudo btrfs subvolume list /mnt/btrfs
}

function bsnr(){
if [ ! -z "$1" ]; then
sudo mv /mnt/btrfs/@home /mnt/btrfs/@home-bad-`date "+%Y-%m%d-%H%M"`
sudo mv /mnt/btrfs/@root /mnt/btrfs/@root-bad-`date "+%Y-%m%d-%H%M"`
sudo mv /mnt/btrfs/@home-$1 /mnt/btrfs/@home
sudo mv /mnt/btrfs/@root-$1 /mnt/btrfs/@root
else
echo "Please input name for delete, eg: bsnd init-snapshot"
fi
sudo ls -al /mnt/btrfs
sudo btrfs subvolume list /mnt/btrfs
}


function gcms(){
git commit -m "update submodules"
}

export NVM_DIR="~/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
