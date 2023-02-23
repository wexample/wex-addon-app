#!/usr/bin/env bash

serviceDirArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'service s "Service to return dir" true'
  )
}

serviceDir() {
  local SERVICES_LOCATIONS
  SERVICES_LOCATIONS+=($(_wexFindAddonsDirs))

  for LOCATION in ${SERVICES_LOCATIONS[@]}
  do
    SERVICE_DIR="${LOCATION}services/${SERVICE}"

    if [ -d "${SERVICE_DIR}" ];then
      echo "${SERVICE_DIR}/"
    fi
  done
}