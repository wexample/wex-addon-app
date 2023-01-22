#!/usr/bin/env bash

appStartedArgs() {
  _ARGUMENTS=(
    'dir d "App root directory" false .'
    'ignore_containers ic "Do not check if containers are also started" false'
  )
}

appStarted() {
  _wexAppGoTo "${DIR}"

  if [ -f "${WEX_FILEPATH_REL_APP_ENV}" ] && [ -f "${WEX_FILEPATH_REL_CONFIG_BUILD}" ];then
    # Load config
    _wexAppGoTo "${DIR}" && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

    # Started && into server
    if [ "${STARTED}" = true ] && [ "$(wex file/lineExists -f="${WEX_PROXY_APPS_REGISTRY}" -l="$(realpath "${DIR}")/")" = true ];then
      # Check if containers are started if expected.
      if [ "${IGNORE_CONTAINERS}" != true ];then
        # At least one container should run.
        # Return true or false.
        wex containers/started
        return
      fi

      # If proxy dont run, no app runs.
      if [ "$(wex app::proxy/started)" = false ];then
        echo false
        return
      fi

      # Do not check containers.
      echo true
      return
    fi
  fi

  echo false
}
