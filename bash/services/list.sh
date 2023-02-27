#!/usr/bin/env bash

servicesListArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Return list of services used by app"
}

servicesList() {
  local SERVICES
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG}"

  # Split
  SERVICES=("$(wex-exec default::string/split -t="${SERVICES}")")
  # Return
  echo "${SERVICES[*]}"
}
