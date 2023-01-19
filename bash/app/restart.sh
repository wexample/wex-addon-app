#!/usr/bin/env bash

appRestartArgs() {
  _ARGUMENTS=(
    'clear_cache cc "Clear all caches" false'
    'if_started is "Restart only if already started" false'
  )
  _AS_SUDO=false
  _AS_SUDO_RUN=true
}

appRestart() {
  # Prevent unwanted restart.
  if [ "${IF_STARTED}" = "true" ] && [ "$(wex app/started -ic)" != true ];then
    return
  fi

  local WEX_ARGUMENTS_BKP=${WEX_ARGUMENTS}

  wex app/stop

  # Remove local config file
  if [ -f "${WEX_FILEPATH_REL_CONFIG_BUILD}" ]; then
      rm "${WEX_FILEPATH_REL_CONFIG_BUILD}"
  fi

  wex app::app/start "${WEX_ARGUMENTS_BKP}"
}
