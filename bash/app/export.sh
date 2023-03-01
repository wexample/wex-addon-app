#!/usr/bin/env bash

appExportArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    "${WEX_APP_ARG_APP_DIR}"
  )
}

appExport() {
  wex-exec hook/exec -c=appExport
}
