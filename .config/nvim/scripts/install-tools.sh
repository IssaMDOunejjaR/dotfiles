#!/bin/bash

# Check if mise is installed, if not install it
# if ! command -v mise &> /dev/null; then
#     echo "Installing mise..."
#     curl https://mise.run | sh
#     # Add mise to shell
#     echo '' >> ~/.bashrc
#     echo 'eval "$(mise activate)"' >> ~/.bashrc
#     echo '' >> ~/.zshrc  
#     echo 'eval "$(mise activate)"' >> ~/.zshrc
#     mkdir -p ~/.config/fish
#     echo '' >> ~/.config/fish/config.fish
#     echo 'eval "$(mise activate)"' >> ~/.config/fish/config.fish
#     # Activate mise for current session
#     eval "$(mise activate)"
# fi

# Install tools with mise first
echo "Installing tools with mise..."
mise use -g \
  lua-language-server@latest \
  stylua@latest

# Install Go tools
echo "Installing Go tools..."
go install golang.org/x/tools/gopls@latest
# go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Install npm packages
echo "Installing npm packages..."
bun add -g \
  @angular/language-server \
  bash-language-server \
  @olrtg/emmet-language-server \
  @biomejs/biome \
  @fsouza/prettierd \
  @tailwindcss/language-server \
  @vtsls/language-server \
  cspell \
  oxlint \
  prettier \
  rustywind \
  typescript-language-server \
  typescript \
  pyright \
  vscode-langservers-extracted

  # Install tools with uv
# echo "Installing tools with uv..."
# uv tool install codespell
# uv tool install isort
# uv tool install pyright
# uv tool install ruff

echo "All tools have been installed successfully!"
