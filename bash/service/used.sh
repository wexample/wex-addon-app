#!/usr/bin/env bash

serviceUsedArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'service s "Service to install" true'
  )
}

serviceUsed() {
  local SERVICES=("$(wex-exec app::services/list)")

  # Array contains
  if [[ " ${SERVICES[*]} " =~ ${SERVICE} ]]; then
    echo true
  else
    echo false
  fi
}
