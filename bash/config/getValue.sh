#!/usr/bin/env bash

configGetValueArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Get value from app config file"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'key k "Target key to change" true'
    'separator s "Separator like space or equal sign, default space" false " "'
    'base b "Use base configuration file" false'
  )
}

configGetValue() {
  local FILE

  if [ "${BASE}" = "true" ]; then
    FILE=${WEX_FILEPATH_REL_CONFIG}
  else
    FILE=${WEX_FILEPATH_REL_CONFIG_BUILD}
  fi

  wex-exec default::config/getValue -f="${FILE}" -s="=" -k="${KEY}"
}
