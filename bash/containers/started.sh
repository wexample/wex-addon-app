#!/usr/bin/env bash

containersStartedArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Return true if one or all containers are started"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'all a "All containers runs" false'
  )
}

containersStarted() {
  # Get site name.
  CONTAINERS=$(wex-exec containers/list -f="${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}")
  # If empty stop here.
  if [ "${CONTAINERS}" = "" ]; then
    # No service, we consider that everything runs.
    echo true
    return
  fi
  CONTAINERS=$(wex-exec array/join -a="${CONTAINERS}" -s=",")
  # Expect all containers runs.
  wex-exec docker::container/started -n="${CONTAINERS}" -a="${ALL}"
}
