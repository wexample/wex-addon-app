#!/usr/bin/env bash

appExportArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'dir d "Application directory" false'
  )
}


appExport() {
  _wexAppGoTo "${DIR:-.}"

  wex-exec hook/exec -c=appExport
}
