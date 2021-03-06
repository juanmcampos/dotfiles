#######################################################
#  Core Requirements:
#    Windows: Git-Bash, Scoop, MonacoYaHei
#      macOS: Homebrew, coreutils
#      Linux:
#######################################################


###################
#     Exports     #
###################
case "$OSTYPE" in
  darwin*)
    # macOS default PATH:
    #   "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    # Add Homebrew super formulae to PATH:
    export PATH="/usr/local/sbin:$PATH"
    # Add Miniconda3 to PATH on macOS:
    export PATH="/usr/local/miniconda3/bin:$PATH"
    # Then stop `brew doctor` from complaining about scripts
    # https://github.com/yyuu/pyenv/issues/106#issuecomment-94921352
    alias brew="env PATH=${PATH//usr\/local\/miniconda3\/bin:/} brew"
    # Add ~/.local/bin to PATH:
    if [[ -d $HOME/.local/bin ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi
    ;;
  linux*)
    # Add Miniconda3 to PATH on Linux:
    if [[ -d /usr/local/miniconda3 ]]; then
      export PATH="/usr/local/miniconda3/bin:$PATH"
    elif [[ -d $HOME/miniconda3 ]]; then
      export PATH="$HOME/miniconda3/bin:$PATH"
    fi
    # Add ~/.local/bin to PATH:
    if [[ -d $HOME/.local/bin ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi
esac
export LANG=en_US.UTF-8
export TZ=UTC-8
# Force enable Node.js (chalk) color,
# cf. https://github.com/chalk/chalk#chalksupportscolor
export FORCE_COLOR=true
# Show git dirty state
export GIT_PS1_SHOWDIRTYSTATE=1
# pipenv exports
export PIPENV_DEFAULT_PYTHON_VERSION=3
export PIPENV_SHELL_FANCY=1
if [[ "$TERM" == "xterm" ]]; then
  export TERM=xterm-256color
fi


########################################
#     Git-Bash (Windows) SSH Agent     #
########################################
# cf. https://help.github.com/articles/working-with-ssh-key-passphrases/#auto-launching-ssh-agent-on-git-for-windows
if [[ $OSTYPE == "msys" ]]; then
  # Your ssh keys storage path
  ssh_key_path=~/.ssh/*.pri
  env=~/.ssh/agent.env
  agent_load_env() {
    test -f "$env" && . "$env" >| /dev/null;
  }
  agent_start() {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ;
  }
  agent_load_env
  # agent_run_state:
  #   0=agent running w/ key;
  #   1=agent w/o key;
  #   2=agent not running.
  agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
  if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add $ssh_key_path
  elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add $ssh_key_path
  fi
  unset ssh_key_path
  unset env
fi


#####################
#     Dircolors     #
#####################
# macOS require GNU gdircolors command, install with `brew install coreutils`.
command -v gdircolors >/dev/null 2>&1 || alias gdircolors="dircolors"
test -f "$HOME/.dircolorsdb" && eval "$(gdircolors -b $HOME/.dircolorsdb)"


###################
#     Aliases     #
###################
lsoption="-F --show-control-chars --group-directories-first --color=auto"
# Make 3 systems' ls command uniform
case "$OSTYPE" in
  darwin*)
    # macOS require GNU gls command, install with `brew install coreutils`.
    alias ls="gls $lsoption"
    ;;
  linux*)
    alias ls="ls $lsoption"
    ;;
  msys*)
    # There are too many unconcerned files and directories in Windows users home, ignore them.
    alias ls="ls $lsoption --ignore={navdb.csv,NTUSER*,ntuser*,Application\ Data,Local\ Settings,My\ Documents,NetHood,PrintHood,Recent,SendTo,Templates,Cookies,3D\ Objects,Thumbs.db,desktop.ini,Start\ Menu,「开始」菜单}"
    ;;
esac
unset lsoption

alias ll="ls -lh"
alias la="ll -A"
alias l="ls"
# Aliases only useful on Git-Bash(Windows)
case "$OSTYPE" in
  darwin*)
    alias here="open ."
    ;;
  msys*)
    alias ipconfig="winpty ipconfig"
    # Add ifconfig to Windows.
    alias ifconfig="ipconfig"
    alias nslookup="winpty nslookup"
    alias ping="winpty ping"
    alias java="winpty java"
    alias python="winpty python"
    alias pip="winpty pip"
    # Open window is only available on macOS, add it to Windows,
    # but no Linux, because I don't use GUI on Linux.
    alias open="explorer"
    alias here="open ."
    ;;
esac
# Aliases useful for all systems
alias c="clear"
alias :q="exit"
alias ..="cd .."
alias ...="cd ../.."
alias gdf="git diff"
alias glg="git lg"
alias gst="git status"
alias ip="curl -s https://api.ip.sb/ip"
# Sometimes I use CMD/PowerShell, which use cls command.
alias cls="clear"
alias ss="all_proxy=socks5://127.0.0.1:1080"


##################
#     Prompt     #
##################
function set_bash_prompt() {
  # Color table
  local   RESET="\[\033[0m\]"
  local   BLACK="\[\033[0;30m\]"
  local     RED="\[\033[0;31m\]"
  local   GREEN="\[\033[0;32m\]"
  local  YELLOW="\[\033[0;33m\]"
  local    BLUE="\[\033[0;34m\]"
  local MAGENTA="\[\033[0;35m\]"
  local    CYAN="\[\033[0;36m\]"
  local   WHITE="\[\033[0;37m\]"
  # Terminal title
  local TERM_TITLE="\[\e]0; \w\a\]"
  # Python virtualenv state; conda-envs will handle itself.
  if [ -z "${VIRTUAL_ENV}" ]; then
    VIRTUALENV=""
  else
    VIRTUALENV=" ${BLUE}[$(basename ${VIRTUAL_ENV})]${RESET}"
  fi
  # PS1 command substitution issue with newline:
  #   https://stackoverflow.com/questions/33220492/
  #   https://stackoverflow.com/questions/21517281/
  PS1="${TERM_TITLE}${GREEN}\h: ${YELLOW}\W${CYAN}\$(__git_ps1 ' (%s)')${RESET}${VIRTUALENV}"$'\n\$ '
}
set_bash_prompt


##########################
#     Other settings     #
##########################
case "$OSTYPE" in
  darwin*)
    # bash-completion:
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
    # rbenv:
    command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"
    ;;
esac
