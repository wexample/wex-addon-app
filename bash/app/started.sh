#!/usr/bin/env bash

appStartedArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Return true if app is started"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    "${WEX_APP_ARG_APP_DIR}"
    'ignore_containers ic "Do not check if containers are also started" false false'
  )
}

appStarted() {
  if [ -f "${WEX_FILEPATH_REL_APP_ENV}" ] && [ -f "${WEX_FILEPATH_REL_CONFIG_BUILD}" ]; then
    # Load config
    . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

    # Started && into server
    if [ "${STARTED}" = true ] && [ "$(wex-exec file/lineExists -f="${WEX_PROXY_APPS_REGISTRY}" -l="$(realpath "${APP_DIR}")/")" = true ]; then
      # Check if containers are started if expected.
      if [ "${IGNORE_CONTAINERS}" != true ]; then
        # At least one container should run.
        # Return true or false.
        STARTED=$(wex-exec containers/started)

        if [ "${STARTED}" = "false" ]; then
          echo false
          return
        fi
      fi

      # If proxy dont run, no app runs.
      if [ "$(wex-exec app::proxy/started)" = false ]; then
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
