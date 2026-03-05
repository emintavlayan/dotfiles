# ============================================================
# Interactive shell guard
# ============================================================
if not status is-interactive
    exit
end


# ============================================================
# Starship prompt
# ============================================================
# Prompt rendering only — fish remains fish
starship init fish | source


# ============================================================
# Pager behavior (for bat, tree | less, etc.)
# ============================================================
# -R : allow colors
# --mouse : enable mouse scrolling
set -gx LESS "-R --mouse"


# ============================================================
# Aliases
# ============================================================

# --- bat instead of cat (interactive only) ---
alias cat="bat"     # Alpine Linux
#alias cat="batcat"  # Ubuntu installs it as `batcat`

# --- tree with paging and colors ---
alias tree="tree -C | less -R"
alias trea="tree -a -C | less -R"


# ============================================================
# Quality-of-life defaults (safe, minimal)
# ============================================================

# Make mkdir create parents by default
alias mkdir="mkdir -p"

# ms dos addictions
alias cls="clear"
alias cd..="cd .."

# ll convinience
alias ll="ls -lh"
alias la="ls -lah"
alias cll="clear; ls -lh"
alias cla="clear; ls -lah"


# ============================================================
# Vim moves in Fish ?! 
# ============================================================

fish_vi_key_bindings


# ============================================================
# Run ssh agent when fish starts 
# ============================================================

if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) >/dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
end


# ============================================================
# Abbreviations
# ============================================================
abbr -a gco git checkout
abbr -a gst git status
abbr -a gcm git commit -m
abbr -a gpl git pull
abbr -a gps git push








