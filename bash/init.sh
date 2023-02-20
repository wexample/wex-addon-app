#!/usr/bin/env bash

export WEX_PROXY_NAME=wex_server

WEX_DIR_PROXY=$([[ "$(uname -s)" == Darwin ]] && echo /Users/.wex/server/ || echo "/opt/${WEX_PROXY_NAME}/") # /opt can't be mounted on macos, using Users instead.

export WEX_APPS_ENVIRONMENTS=(local dev prod)
export WEX_DIR_APP_TMP=${WEX_DIR_APP_DATA}tmp/
export WEX_DIR_PROXY
export WEX_DIR_PROXY_TMP=${WEX_DIR_PROXY}tmp/
export WEX_FILE_APP_ENV=.env
export WEX_FILE_SERVICE_CONFIG=service.config
export WEX_FILEPATH_REL_APP_ENV=${WEX_DIR_APP_DATA}${WEX_FILE_APP_ENV}
export WEX_FILEPATH_REL_COMPOSE_BUILD_YML=${WEX_DIR_APP_TMP}docker-compose.build.yml
export WEX_FILEPATH_REL_CONFIG_BUILD=${WEX_DIR_APP_TMP}config.build
export WEX_FILEPATH_REL_CONFIG=${WEX_DIR_APP_DATA}config
export WEX_PROXY_APPS_REGISTRY=${WEX_DIR_PROXY_TMP}apps
export WEX_PROXY_HOSTS_REGISTRY=${WEX_DIR_PROXY_TMP}hosts

case "${WEX_OS}" in
  "linux" | "mac")
    export WEX_SYSTEM_HOST_FILE=/etc/hosts
    ;;
  "windows")
    export WEX_SYSTEM_HOST_FILE='C:\Windows\System32\drivers\etc\hosts'
    ;;
esac

_wexAppGoTo() {
  local LOCATION

  LOCATION=$(wex-exec app::app/locate -d="${1}")
  if [ "${LOCATION}" = "" ]; then
    _wexError "No app found ${1}, did you create a .wex/.env file ?"
    exit 0
  fi

  cd "${LOCATION}"
}

export -f _wexAppGoTo