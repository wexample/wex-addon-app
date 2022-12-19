#!/usr/bin/env bash

containersStartedArgs() {
  _ARGUMENTS=(
    'all a "All containers runs" false'
  )
}

containersStarted() {
  # Get site name.
  CONTAINERS=$(wex containers/list -f="${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}")
  # If empty stop here.
  if [ "${CONTAINERS}" = "" ];then
    # No service, we consider that everything runs.
    echo true
    return
  fi
  CONTAINERS=$(wex array/join -a="${CONTAINERS}" -s=",")
  # Expect all containers runs.
  wex docker::container/started -n="${CONTAINERS}" -a="${ALL}"
}
