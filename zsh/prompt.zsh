autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

git=`which git`

git_current_branch() {
  branch=("$($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})")

  if [[ $branch != "" ]]; then
    remote=("$($git config branch.$branch.remote | tr -d '\n')")
    if [[ $remote != "" ]]; then
      echo " on $(color_value $remote/$branch cyan)"
    else
      echo " on $(color_value $branch cyan)"
    fi
  else
    hash=("$($git rev-parse --short HEAD)")
    echo " on $(color_value $hash yellow)"
  fi
}

git_stashes() {
  stash=${$($git stash list 2>/dev/null | wc -l | tr -d " ")}
  if [[ $stash == "0" ]]
  then
    echo ""
  else
    echo " {$(color_value $stash cyan)}"
  fi
}

color_value() {
  if [[ $1 == "0" ]]; then
    echo $1
  else
    echo %{$fg_bold[$2]%}$1%{$reset_color%}
  fi
}

git_untracked_changed_staged() {
  git_status=("${(f)$($git status --porcelain --untracked-files=all 2>/dev/null | cut -c1-2)}")
  untracked=0
  changed=0
  staged=0
  for line ($git_status) {
    if [[ $line =~ "[MADRC][MD ]" ]]; then
      (( staged = $staged + 1 ))
    fi

    if [[ $line =~ "\?\?" ]]; then
      (( untracked = $untracked + 1 ))
    elif [[ $line =~ "[MADRC ][MD]" ]]; then
      (( changed = $changed + 1 ))
    fi
  }

  if [[ $untracked == 0 && $changed == 0 && $staged == 0 ]];then
    echo ""
  else
    echo " $(color_value $untracked red):$(color_value $changed red):$(color_value $staged red)"
  fi
}

git_dirty() {
  st=$($git status 2>/dev/null | wc -l | tr -d " ")
  if [[ $st == "0" ]]
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
    behind=${$($git rev-list --left-right --count @{upstream}...$branch | awk {'print $1'})}
    ahead=${$($git rev-list --left-right --count @{upstream}...$branch | awk {'print $2'})}
    if [[ $ahead == "0" && $behind == "0" ]]
    then
      echo ""
    else
      echo -n " ["
      if [[ $behind != "0" ]]
      then
        echo -n "-$(color_value $behind cyan)"
        if [[ $ahead != "0" ]]
        then
          echo -n "/"
        fi
      fi
      if [[ $ahead != "0" ]]
      then
        echo -n "+$(color_value $ahead cyan)"
      fi
      echo -n "]"
    fi
  fi
}

location() {
  # echo "$(color_value $USERNAME@$HOST cyan)"
  if [[ $VAULTED_ENV == "" ]]
  then
    echo "$(color_value $USERNAME cyan)"
  else
    echo "$(color_value $USERNAME cyan):$(color_value $VAULTED_ENV red)"
  fi
}

directory_name() {
  echo "$(color_value $PWD green)"
}

export PS1=$'[$(location):$(directory_name)]$(git_dirty)\n$ '
