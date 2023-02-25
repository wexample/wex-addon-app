#!/usr/bin/env bash

appComposeArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'command c "Command to execute" true'
  )
}

appCompose() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG}"

  local COMPOSE_FILES
  if [ "$(wex-exec service/used -s=proxy)" = false ]; then
    # Contains containers network configuration.
    COMPOSE_FILES="-f ${WEX_DIR_ADDONS}app/containers/default/docker-compose.yml"
  else
    # Contains proxy network configuration.
    COMPOSE_FILES="-f ${WEX_DIR_ADDONS}app/containers/network/docker-compose.yml"
  fi

  local FILES=(
    # Base docker file / may extend global container.
    "${WEX_DIR_APP_DATA}docker/docker-compose.yml"
  )

  # Env specific file
  local ENV_YML="${WEX_DIR_APP_DATA}docker/docker-compose."${APP_ENV}".yml"
  if [ -f "${ENV_YML}" ]; then
    FILES+=("${ENV_YML}")
  fi

  for FILE in ${FILES[@]}; do
    # File exists.
    if [ -f "${FILE}" ]; then
      COMPOSE_FILES=${COMPOSE_FILES}" -f "${FILE}
    fi
  done

  docker compose ${COMPOSE_FILES} --env-file "${WEX_FILEPATH_REL_CONFIG_BUILD}" "${COMMAND}"
}
