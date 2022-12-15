#!/usr/bin/env bash

configLoadArgs() {
  _DESCRIPTION="Search into parent tree if current folder is in a wex project. Returns the wex project real path if found"
  _ARGUMENTS=(
    'dir d "Starting directory" false'
  )
}

configLoad() {
  local LOCATION
  LOCATION=$(wex app::app/locate -d="${DIR}")

  if [ "${LOCATION}" != "" ];then
    . "${LOCATION}${WEX_FILE_APP_FOLDER}/${WEX_FILE_APP_ENV}"
  fi
}
