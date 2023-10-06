#!/bin/bash

ret=$(find $HOME -type d -print | fzf &)

wait $!

session_name=$(echo $ret | sed "s/\./\_/")

echo "$ret"

tmux new-session -d -A -D -s "$session_name" -c "$ret"; tmux switch -t "$session_name"
