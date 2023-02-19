#!/usr/bin/env bash

servicesList() {
  local SERVICES
  # From config.
  SERVICES=$(wex app::app/config -k=SERVICES)
  # Split
  SERVICES=("$(wex default::string/split -t="${SERVICES}")")
  # Return
  echo "${SERVICES[*]}"
}
