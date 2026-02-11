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
# Yazi
# ============================================================

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
