#!/usr/bin/env bash

appEnvArgs() {
  _NEEDS_APP_LOCATION=true
  _ARGUMENTS=(
    'dir d "Application directory" false'
  )
}

appEnv() {
  _wexAppGoTo "${DIR:-.}"

  cd "$(wex-exec app::app/locate -d="${DIR}")"

  if [ -f "${WEX_FILEPATH_REL_APP_ENV}" ]; then
    wex-exec bash/readVar -f="${WEX_FILEPATH_REL_APP_ENV}" -k=APP_ENV
  fi
}
