#!/usr/bin/env bash

appStartedArgs() {
  _ARGUMENTS=(
    'dir d "Root site directory" false'
    'ignore_containers ic "Do not check if containers are also started" false'
  )
}

appStarted() {
  cd "$(wex app::app/locate -d="${DIR}")"

  if [ -f "${WEX_FILEPATH_REL_APP_ENV}" ];then
    # Load config
    _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG}"
    # Started && into server
    if [ "${STARTED}" = true ] && [ "$(wex file/lineExists -f="${WEX_PROXY_APPS_REGISTRY}" -l="$(realpath "${DIR}")/")" = true ];then
      # Check if containers are started if expected.
      if [ "${IGNORE_CONTAINERS}" != true ];then
        # At least one container should run.
        # Return true or false.
        wex containers/started
        return
      fi
      # Do not check containers.
      echo true
      return
    fi
  fi

  # Check if proxy runs at end, for performance.
  if [ "$(wex app::proxy/started)" = false ];then
    echo false
    return
  fi

  echo false
}
