#!/usr/bin/env bash

appExportArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'dir d "Application directory" false'
  )
}


appExport() {
  _wexAppGoTo "${DIR:-.}"

  wex-exec hook/exec -c=appExport
}
