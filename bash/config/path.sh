#!/usr/bin/env bash

configPathArgs() {
  _DESCRIPTION="Search into parent tree if current folder is in a wex project. Returns the wex project real path if found"
  _ARGUMENTS=(
    'dir d "Starting directory" false'
  )
}

configPath() {
  local CONFIG
  CONFIG="$(wex app::app/locate -d="${DIR}")${WEX_FILEPATH_REL_CONFIG}"

  if [ -f "${CONFIG}" ];then
    echo "${DIR}${WEX_FILEPATH_REL_CONFIG}"
  fi
}
