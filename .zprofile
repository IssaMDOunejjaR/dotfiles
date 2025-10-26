if [ "$TMUX" = "" ]; then tmux attach -t home || tmux new -s home; fi
