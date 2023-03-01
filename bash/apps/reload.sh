#!/usr/bin/env bash

appsReloadArgs() {
  _DESCRIPTION="Rebuilds apps registry"
  _AS_NON_SUDO=false
}

appsReload() {
  touch "${WEX_PROXY_APPS_REGISTRY}"

  # Load sites list
  local APPS_PATHS=($(cat ${WEX_PROXY_APPS_REGISTRY}))
  local DIR_CURRENT=$(realpath ./)
  # Rebuild sites list.
  local APPS_PATHS_FILTERED=()
  local APPS_LIST=""

  if [ "$(wex-exec proxy/started)" = true ]; then
    for APP_PATH in ${APPS_PATHS[@]}; do
      local EXISTS=false
      local CONFIG=${APP_PATH}${WEX_FILEPATH_REL_CONFIG_BUILD}

      # Config must exist.
      if [ -f "${CONFIG}" ]; then
        # Prevent duplicates
        for SITE_SEARCH in ${APPS_PATHS_FILTERED[@]}; do
          if [ "${SITE_SEARCH}" = "${APP_PATH}" ]; then
            EXISTS=true
          fi
        done

        # Load config.
        . "${CONFIG}"

        if [ "${EXISTS}" = false ] && [ "${STARTED}" = true ]; then
          if [ "$(wex-exec app::app/started -d="${APP_PATH}")" = true ]; then
            APPS_PATHS_FILTERED+=(${APP_PATH})
            APPS_LIST+="\n"${APP_PATH}
          fi
        fi
      fi
    done
  fi

  cd "${DIR_CURRENT}"

  # Store sites list.
  echo -e "${APPS_LIST}" | tee "${WEX_PROXY_APPS_REGISTRY}" >/dev/null
}
