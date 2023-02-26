#!/usr/bin/env bash

appPermsArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'dir d "Application directory" false'
  )
}

appPerms() {
  _wexAppGoTo "${DIR:-.}"

  wex-exec hook/exec -c=appPerms
}
