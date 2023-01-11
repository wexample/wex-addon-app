#!/usr/bin/env bash

configGetValueArgs() {
  _ARGUMENTS=(
   'key k "Target key to change" true'
   'separator s "Separator like space or equal sign, default space" false " "'
   'base b "Use base configuration file" false'
  )
}

configGetValue() {
  local FILE

  if [ "${BASE}" = "true" ];then
    FILE=${WEX_FILEPATH_REL_CONFIG}
  else
    FILE=${WEX_FILEPATH_REL_CONFIG_BUILD}
  fi

  wex config/getValue -f="${FILE}" -s="=" -k="${KEY}"
}
