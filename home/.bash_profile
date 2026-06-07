# ~/.bash_profile -- run for login shells (incl. most SSH sessions and macOS
# Terminal).  Keep login-shell logic minimal: just pull in ~/.bashrc so
# interactive settings apply everywhere.
[ -r "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
