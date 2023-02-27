#!/usr/bin/env bash

appImportArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'dir d "Application directory" false'
  )
}

appImport() {
  _wexAppGoTo "${DIR:-.}"

  wex-exec hook/exec -c=appImport
}
