#!/usr/bin/env bash

containersListArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'remove_prefix rm "Remove the name of the site from container name" false'
    'file_compose f "Docker compose file" false'
  )
}

containersList() {
  local CONFIG_YML=$(wex-exec app::config/yml -f="${FILE_COMPOSE}")
  local SEARCH_VAR="container_name"
  local CONTAINERS=()

  # Remove prefix
  if [ "${REMOVE_PREFIX}" = true ];then
    _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG}"

    REGEX="s/^services_\(.*\)_\?${SEARCH_VAR}\=\"${APP_NAME}_\(.*\)\"\$/\2/p"
  else
    REGEX="s/^services_\(.*\)_\?${SEARCH_VAR}\=\"\?\(.*\)\"\$/\2/p"
  fi

  for COMPOSE_VAR in ${CONFIG_YML[@]}
  do
    CONTAINER_NAME=$(sed -n ${REGEX} <<< "${COMPOSE_VAR}")
    if [[ ${CONTAINER_NAME} ]];then
      CONTAINERS+=(${CONTAINER_NAME})
    fi
  done;

  echo ${CONTAINERS[@]}
}
