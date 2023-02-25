#!/usr/bin/env bash

appsListArgs() {
  _DESCRIPTION="List of all running apps"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'all a "Return raw list without testing activity" false'
    'count c "Return only number of sites found" false'
  )
}

# Return actively running sites list.
appsList() {
  if [ ! -f "${WEX_PROXY_APPS_REGISTRY}" ]; then
    if [ "${COUNT}" = "true" ]; then
      echo "0"
    fi
    return
  fi

  local REGISTRY=$(cat "${WEX_PROXY_APPS_REGISTRY}")
  local SITES_COUNT=0
  local SITES=()

  for APP_PATH in ${REGISTRY[@]}; do
    # Trim
    APP_PATH=$(echo -e "${APP_PATH}" | sed -e 's/^[[:space:]]\{0,\}//' -e 's/[[:space:]]\{0,\}$//')
    # Avoid blank lines.
    if [[ ${APP_PATH} != "" ]]; then
      EXISTS=false

      if [ "${ALL}" != '' ]; then
        SITES+=($(basename ${APP_PATH}))
        ((SITES_COUNT++))
      else
        # Prevent duplicates
        for SITE_SEARCH in ${SITES[@]}; do
          if [[ ${SITE_SEARCH} == ${APP_PATH} ]]; then
            EXISTS=true
          fi
        done

        if [ ${EXISTS} == false ] && [ $(wex-exec app::app/started -d=${APP_PATH}) == true ]; then
          . "${APP_PATH}${WEX_FILEPATH_REL_CONFIG}"
          SITES+=(${APP_NAME})
          ((SITES_COUNT++))
        fi
      fi
    fi
  done

  if [ "${COUNT}" == "true" ]; then
    echo "${SITES_COUNT}"
  else
    echo ${SITES[@]}
  fi
}
