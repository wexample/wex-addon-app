#!/usr/bin/env bash

appPermsArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'app_dir ad "Application directory" false'
  )
}

appPerms() {
  wex-exec hook/exec -c=appPerms
}
