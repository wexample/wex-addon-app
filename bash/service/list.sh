#!/usr/bin/env bash

serviceList() {
  local SERVICES
  # From config.
  SERVICES=$(wex app::app/config -k=services)
  # Split
  SERVICES=("$(wex default::string/split -t="${SERVICES}")")
  # Return
  echo "${SERVICES[*]}"
}
