#!/usr/bin/env bash

serviceUsedArgs() {
  _ARGUMENTS=(
    'service s "Service to install" true'
  )
}

serviceUsed() {
  local SERVICES=("$(wex app::service/list)")

  # Array contains
  if [[ " ${SERVICES[*]} " =~ ${SERVICE} ]]; then
    echo true
  else
    echo false
  fi
}