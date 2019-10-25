#!/bin/bash

# Colors
# ######
ESC="\033"
DULL=0
BRIGHT=1
NORMAL_COLOR="\[$ESC[m\]"

##
# Shortcuts for Colored Text ( Bright and FG Only )
##
# DULL TEXT
BLACK="\[$ESC[${DULL};30m\]"
RED="\[$ESC[${DULL};31m\]"
GREEN="\[$ESC[${DULL};32m\]"
YELLOW="\[$ESC[${DULL};33m\]"
BLUE="\[$ESC[${DULL};34m\]"
VIOLET="\[$ESC[${DULL};35m\]"
CYAN="\[$ESC[${DULL};36m\]"
WHITE="\[$ESC[${DULL};37m\]"

# BRIGHT TEXT
BRIGHT_BLACK="\[$ESC[${BRIGHT};30m\]"
BRIGHT_RED="\[$ESC[${BRIGHT};31m\]"
BRIGHT_GREEN="\[$ESC[${BRIGHT};32m\]"
BRIGHT_YELLOW="\[$ESC[${BRIGHT};33m\]"
BRIGHT_BLUE="\[$ESC[${BRIGHT};34m\]"
BRIGHT_VIOLET="\[$ESC[${BRIGHT};35m\]"
BRIGHT_CYAN="\[$ESC[${BRIGHT};36m\]"
BRIGHT_WHITE="\[$ESC[${BRIGHT};37m\]"

git=`which git`

git_current_branch() {
  branch=("$($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})")

  if [[ $branch != "" ]]; then
    remote=("$($git config branch.$branch.remote | tr -d '\n')")
    if [[ $remote != "" ]]; then
      echo " on $(color_value $remote/$branch $BRIGHT_CYAN)"
    else
      echo " on $(color_value $branch $BRIGHT_CYAN)"
    fi
  else
    hash=("$($git rev-parse --short HEAD)")
    echo " on $(color_value $hash $BRIGHT_YELLOW)"
  fi
}

git_stashes() {
  stash=$($git stash list 2>/dev/null | wc -l | tr -d " ")
  if [[ $stash == "0" ]]
  then
    echo ""
  else
    echo " {$(color_value $stash $BRIGHT_CYAN)}"
  fi
}

color_value() {
  if [[ $1 == "0" ]]; then
    echo $1
  else
    echo $2$1$NORMAL_COLOR
  fi
}

git_untracked_changed_staged() {
  git_status="$($git status --porcelain --untracked-files=all | tr " " "." | cut -c1-2)"
  untracked=0
  changed=0
  staged=0
  for line in $git_status
  do
    if [[ "$line" =~ [MADRC][MD.] ]]; then
      (( staged = $staged + 1 ))
    fi

    if [[ $line =~ \?\? ]]; then
      (( untracked = $untracked + 1 ))
    elif [[ $line =~ [MADRC.][MD] ]]; then
      (( changed = $changed + 1 ))
    fi
  done

  if [[ $untracked == 0 && $changed == 0 && $staged == 0 ]];then
    echo ""
  else
    echo " $(color_value $untracked $BRIGHT_RED):$(color_value $changed $BRIGHT_RED):$(color_value $staged $BRIGHT_RED)"
  fi
}

git_dirty() {
  st=$($git status 2>/dev/null | tail -n 1)
  if [[ $st == "" ]]
  then
    echo ""
  else
    echo "$(git_current_branch)$(git_stashes)$(git_untracked_changed_staged)$(git_commits)"
  fi
}

git_commits() {
  branch=("$($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})")
  remote=("$($git config branch.$branch.remote | tr -d '\n')")

  if [[ $remote == "" ]]
  then
    echo ""
  else
    behind=$($git rev-list --left-right --count @{upstream}...$branch | awk {'print $1'})
    ahead=$($git rev-list --left-right --count @{upstream}...$branch | awk {'print $2'})
    if [[ $ahead == "0" && $behind == "0" ]]
    then
      echo ""
    else
      echo -n " ["
      if [[ $behind != "0" ]]
      then
        echo -n "-$(color_value $behind $BRIGHT_CYAN)"
        if [[ $ahead != "0" ]]
        then
          echo -n "/"
        fi
      fi
      if [[ $ahead != "0" ]]
      then
        echo -n "+$(color_value $ahead $BRIGHT_CYAN)"
      fi
      echo -n "]"
    fi
  fi
}

location() {
  echo "$(color_value `whoami`@`hostname` $BRIGHT_CYAN)"
}

directory_name() {
  echo "$(color_value `pwd` $BRIGHT_GREEN)"
}

prompt_command() {
  export PS1="[$(location):$(directory_name)]$(git_dirty)\n$ "
}

PROMPT_COMMAND=prompt_command

#
