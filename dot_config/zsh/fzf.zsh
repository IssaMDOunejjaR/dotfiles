# fzf

source <(fzf --zsh)

# --- Completion Styling ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Use eza --tree for a gorgeous preview when tab-completing cd/zoxide
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always --level=2 $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --color=always --level=2 $realpath'

# Preview files when tab-completing file paths
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --style=numbers --color=always $realpath 2>/dev/null || eza --color=always $realpath'
