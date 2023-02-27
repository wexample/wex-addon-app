#!/usr/bin/env bash

serviceUsedArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Returns true if service is used"
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
