#!/usr/bin/env bash

appComposeArgs() {
  _ARGUMENTS=(
    'command c "Command to execute" true'
  )
}

appCompose() {
  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG}"

  # Load expected env file.
  local APP_ENV=$(wex app/env)
  local SERVICES=($(wex app::services/all))
  local SERVICE_DIR
  local SERVICE_UPPERCASE
  local VAR_NAME
  local YML_INHERIT

  printf "\n" >> "${WEX_FILEPATH_REL_CONFIG_BUILD}"
  wex app::config/addTitle -t="Compose files\n"

  # Iterate through array using a counter
  for SERVICE in "${SERVICES[@]}"
  do
      SERVICE_UPPERCASE=$(wex string/toScreamingSnake -t="${SERVICE}")
      SERVICE_DIR=$(wex service/dir -s="${SERVICE}")

      VAR_NAME="WEX_COMPOSE_YML_"${SERVICE_UPPERCASE}"_BASE"
      YML_INHERIT="${SERVICE_DIR}docker/docker-compose.yml"
      wex app::config/setValue -k="${VAR_NAME}" -v="${YML_INHERIT}"

      local VAR_NAME="WEX_COMPOSE_YML_"${SERVICE_UPPERCASE}
      local YML_INHERIT_ENV="${SERVICE_DIR}docker/docker-compose."${APP_ENV}".yml"

      if [ -f "${YML_INHERIT_ENV}" ];then
        wex app::config/setValue -k="${VAR_NAME}" -v="${YML_INHERIT_ENV}"
      else
        wex app::config/setValue -k="${VAR_NAME}" -v="${YML_INHERIT}"
      fi
  done

  local COMPOSE_FILES
  if [ "$(wex service/used -s=proxy)" = false ];then
    COMPOSE_FILES="-f ${WEX_DIR_ADDONS}app/containers/default/docker-compose.yml"
  else
    COMPOSE_FILES="-f ${WEX_DIR_ADDONS}app/containers/network/docker-compose.yml"
  fi

  local FILES=(
    # Base docker file / may extend global container.
    "${WEX_DIR_APP_DATA}docker/docker-compose.yml"
    # Env specific file
    "${WEX_DIR_APP_DATA}docker/docker-compose."${APP_ENV}".yml"
  );

  for FILE in ${FILES[@]}
  do
    # File exists.
    if [ -f "${FILE}" ]; then
      COMPOSE_FILES=${COMPOSE_FILES}" -f "${FILE}
    fi;
  done;

  docker-compose ${COMPOSE_FILES} --env-file="${WEX_FILEPATH_REL_CONFIG_BUILD}" "${COMMAND}"
}
