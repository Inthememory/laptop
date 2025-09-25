#!/usr/bin/env bash

laptop_logo() {
  laptop_memory_logo
  echo -e "$BRACKET\n"
  cat <<-"EOF"
┏┳┓┏━╸┏┳┓┏━┓┏━┓╻ ╻   ╻  ┏━┓┏━┓╺┳╸┏━┓┏━┓
┃┃┃┣╸ ┃┃┃┃ ┃┣┳┛┗┳┛   ┃  ┣━┫┣━┛ ┃ ┃ ┃┣━┛
╹ ╹┗━╸╹ ╹┗━┛╹┗╸ ╹    ┗━╸╹ ╹╹   ╹ ┗━┛╹
───────────────────────────────────────

EOF
  echo -e "$NORMAL"
}
