#!/usr/bin/env bash

servicesAllArgs() {
  _DESCRIPTION="Return list of all services including core and addons"
}

servicesAll() {
  local ADDONS_DIRS=$(_wexFindAddonsDirs)
  local DIR
  local OUTPUT=()

  for DIR in ${ADDONS_DIRS[@]}; do
    DIR=${DIR}services/

    if [ -d "${DIR}" ]; then
      OUTPUT+=($(ls ${DIR}))
    fi
  done

  echo "${OUTPUT[@]}"
}
