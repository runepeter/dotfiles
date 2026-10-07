# 20-tooling — interaktive CLI-verktøy.
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
# fzf: behold Ctrl-T + Alt-C, la atuin få Ctrl-R (unbind fzf sin).
command -v fzf >/dev/null && { source <(fzf --zsh); bindkey -r '^R'; }
# atuin: behold Ctrl-R, IKKE rebind pil opp (behold p10k-historikk på pil opp).
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v bat >/dev/null && alias cat='bat --paging=never'
