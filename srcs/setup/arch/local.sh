#!/bin/bash

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  if gum spin --show-error --title "Install Tmux plugin manager..." -- git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
    gum log --time "$time_type" -l info ":" Tmux plugin manager installed.
  else
    gum log --time "$time_type" -l error ":" Failed to install Tmux plugin manager.
    exit 1
  fi
fi

if [ ! -d "$HOME/.local/bin" ]; then
  if gum spin --show-error --title "Create .local/bin..." -- mkdir -p "$HOME/.local/bin"; then
    gum log --time "$time_type" -l info ":" .local/bin created.
  else
    gum log --time "$time_type" -l error ":" Failed to create .local/bin.
    exit 1
  fi
fi

if [ ! -f "$HOME/.local/bin/tmux-sessionizer" ]; then
  if gum spin --show-error --title "Install Tmux Sessionizer..." -- cp "$dotfiles/srcs/tmux-sessionizer" "$HOME/.local/bin/"; then
    gum log --time "$time_type" -l info ":" Tmux Sessionizer installed.
  else
    gum log --time "$time_type" -l error ":" Failed to install Tmux Sessionizer.
    exit 1
  fi
fi

cd "$dotfiles" || exit 1

if gum spin --show-error --title "Install config files..." -- stow --adopt .; then
  git restore .
  gum log --time "$time_type" -l info ":" Config files installed.
else
  gum log --time "$time_type" -l error ":" Failed to install config files.
  exit 1
fi

cd - &>/dev/null || exit 1

if gum spin --show-error --title "Install Node LTS using fnm ..." -- "$(which fnm)" install --lts; then
  git restore .
  gum log --time "$time_type" -l info ":" Node installed.
else
  gum log --time "$time_type" -l error ":" Failed to install Node.
  exit 1
fi

if gum spin --show-error --title "Create the 'Projects' and 'Learning' folders..." -- mkdir -p "$HOME/Documents/{Learning,Projects}" ; then
  git restore .
  gum log --time "$time_type" -l info ":" Node installed.
else
  gum log --time "$time_type" -l error ":" Failed to install Node.
  exit 1
fi
