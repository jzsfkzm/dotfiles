autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

if (( $+commands[grep] ))
then
  grep="$commands[grep]"
else
  grep="/usr/bin/grep"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_stash() {
  stash=${$($git stash list 2>/dev/null | wc -l)// /}
  if [[ $stash == "0" ]]
  then
    echo ""
  else
    echo "%{$fg_bold[cyan]%}[$stash]%{$reset_color%} "
  fi
}

git_new() {

}

git_new_changed_staged() {
  git_status=("${(f)$($git status --porcelain | cut -c1-2)}")
  integer new=0
  integer changed=0
  integer staged=0
  for line ($git_status) {
    if [[ $line =~ "[MADRC][ MD]" ]]; then
      (( staged = $staged + 1 ))
    fi

    if [[ $line =~ "\?\?" ]]; then
      (( new = $new + 1 ))
    elif [[ $line =~ "[MADRC ][MD]" ]]; then
      (( changed = $changed + 1 ))
    fi
  }

  echo "%{$fg_bold[red]%}$new%{$reset_color%}:%{$fg_bold[red]%}$changed%{$reset_color%}:%{$fg_bold[red]%}$staged%{$reset_color%}"
}

git_dirty() {
  st=$($git status 2>/dev/null | tail -n 1)
  if [[ $st == "" ]]
  then
    echo ""
  else
    echo "(%{$fg_bold[cyan]%}$(git_branch)%{$reset_color%}) $(git_stash)$(git_new_changed_staged)"
  fi
}

git_branch() {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
 echo "${ref#refs/heads/}"
}

git_commits() {
  commits=${$($git cherry -v @{upstream} 2>/dev/null | wc -l)// /}
  if [[ $commits == "0" ]]
  then
    echo ""
  else
    echo " [%{$fg_bold[red]%}$commits%{$reset_color%}]"
  fi
}

# This keeps the number of todos always available the right hand side of my
# command line. I filter it to only count those tagged as "+next", so it's more
# of a motivation to clear out the list.
todo(){
  if (( $+commands[todo.sh] ))
  then
    num=$(echo $(todo.sh ls +next | wc -l))
    let todos=num-2
    if [ $todos != 0 ]
    then
      echo "$todos"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

location(){
  echo "%{$fg_bold[cyan]%}$USERNAME@$HOST%{$reset_color%}"
}

directory_name(){
  echo "%{$fg_bold[green]%}$PWD%{$reset_color%}"
}

export PROMPT=$'[$(location):$(directory_name)] $(git_dirty)$(git_commits)\n$ '
set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}$(todo)%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
