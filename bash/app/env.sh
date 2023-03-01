#!/usr/bin/env bash

appEnvArgs() {
  _NEEDS_APP_LOCATION=true
  _ARGUMENTS=(
    'app_dir ad "Application directory" false'
  )
}

appEnv() {
  cd "$(wex-exec app::app/locate -ad="${APP_DIR}")"

  if [ -f "${WEX_FILEPATH_REL_APP_ENV}" ]; then
    wex-exec bash/readVar -f="${WEX_FILEPATH_REL_APP_ENV}" -k=APP_ENV
  fi
}
