#!/usr/bin/env bash

servicesList() {
  local SERVICES
  # From config.
  SERVICES=$(wex-exec app::app/config -k=SERVICES)
  # Split
  SERVICES=("$(wex-exec default::string/split -t="${SERVICES}")")
  # Return
  echo "${SERVICES[*]}"
}
