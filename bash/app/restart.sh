#!/usr/bin/env bash

appRestartArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Retarts app"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'clear_cache cc "Clear all caches" false'
    'dir d "Application directory" false'
    'if_started is "Restart only if already started" false'
    'user u "Owner of application files" false www-data'
  )
  _AS_NON_SUDO=false
}

appRestart() {
  _wexAppGoTo "${DIR:-.}"

  # Prevent unwanted restart.
  if [ "${IF_STARTED}" = "true" ] && [ "$(wex-exec app::app/started -ic)" != true ]; then
    return
  fi

  local WEX_ARGUMENTS_BKP=${WEX_ARGUMENTS}

  wex-exec app::app/stop

  # Remove local config file
  if [ -f "${WEX_FILEPATH_REL_CONFIG_BUILD}" ]; then
    rm "${WEX_FILEPATH_REL_CONFIG_BUILD}"
  fi

  wex-exec app::app/start "${WEX_ARGUMENTS_BKP}" -u="${USER}"
}
