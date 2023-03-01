#!/usr/bin/env bash

appPermsArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'dir d "Application directory" false'
  )
}

appPerms() {
  wex-exec hook/exec -c=appPerms
}
