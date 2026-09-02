#!/usr/bin/env bash

vusion_logo_small() {
  # Check if the terminal supports colors


  local bold yellow reset style
  bold=$(laptop_ansi bold)
  if [ -t 1 ]; then
    yellow="\e[38;5;221m"
  fi
  reset=$(laptop_ansi reset)
  style="${bold}${yellow}"

  local tl="╭" tr="╮" bl="╰" br="╯" h="─" v="│" left="╲" right="╱"

  # Box drawing arcs and diagonals need a UTF-8 locale, fall back to ASCII
  case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *[Uu][Tt][Ff]*) ;;
    *) tl="+" tr="+" bl="+" br="+" h="-" v="|" left="\\\\" right="/" ;;
  esac

  printf "%b\n" "\
  ${style}${tl}${h}${h}${h}${h}${tr}${reset}
  ${style}${v} ${left}${right} ${v} VUSION SHELL${reset}
  ${style}${bl}${h}${h}${h}${h}${br}${reset}"
}
