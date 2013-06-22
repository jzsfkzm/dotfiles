autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_current_branch() {
  echo " on $(color_value $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'}) cyan)"
}

git_stashes() {
  stash=${$($git stash list 2>/dev/null | wc -l)// /}
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
  git_status=("${(f)$($git status --porcelain --untracked-files=all | cut -c1-2)}")
  integer untracked=0
  integer changed=0
  integer staged=0
  for line ($git_status) {
    if [[ $line =~ "[MADRC][ MD]" ]]; then
      (( staged = $staged + 1 ))
    fi

    if [[ $line =~ "\?\?" ]]; then
      (( untracked = $untracked + 1 ))
    elif [[ $line =~ "[MADRC ][MD]" ]]; then
      (( changed = $changed + 1 ))
    fi
  }

  echo " $(color_value $untracked red):$(color_value $changed red):$(color_value $staged red)"
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
  commits=${$($git cherry -v @{upstream} 2>/dev/null | wc -l)// /}
  if [[ $commits == "0" ]]
  then
    echo ""
  else
    echo " [$(color_value $commits cyan)]"
  fi
}

location(){
  echo "$(color_value $USERNAME@$HOST cyan)"
}

directory_name(){
  echo "$(color_value $PWD green)"
}

export PROMPT=$'[$(location):$(directory_name)]$(git_dirty)\n$ '

precmd() {
  title "zsh" "%m" "%55<...<%~"
}
