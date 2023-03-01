#!/usr/bin/env bash

appPermsArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    "${WEX_APP_ARG_APP_DIR}"
  )
}

appPerms() {
  wex-exec hook/exec -c=appPerms
}
