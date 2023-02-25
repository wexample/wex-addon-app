#!/usr/bin/env bash

servicesList() {
  local SERVICES
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG}"

  # Split
  SERVICES=("$(wex-exec default::string/split -t="${SERVICES}")")
  # Return
  echo "${SERVICES[*]}"
}
