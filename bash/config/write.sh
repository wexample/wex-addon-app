#!/usr/bin/env bash

configWriteArgs() {
  _ARGUMENTS=(
    'started s "Set the site is started or not" false'
    'no_recreate nr "No recreate if files exists" false'
    'dir d "Application directory" false'
    'user u "Owner of application files" false www-data'
  )
  _AS_NON_SUDO=false
}

configWrite() {
  # No recreate.
  if [ "${NO_RECREATE}" = true ] &&
    [ -f "${WEX_FILEPATH_REL_CONFIG_BUILD}" ] &&
    [ -f "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" ]; then

    _wexLog "App config file exists. No recreating."
    return
  fi

  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG}"

  _wexLog "Creating temporary folder : ${WEX_DIR_APP_TMP}"
  # Create temp dirs if not exists.
  mkdir -p "${WEX_DIR_APP_TMP}"
  ${WEX_CHOWN_NON_SUDO_COMMAND} -R "${WEX_DIR_APP_TMP}"

  if [ "${STARTED}" != true ]; then
    STARTED=false
  fi

  local APP_ENV
  APP_ENV=$(wex-exec app::app/env)

  local APP_ENV_UPPER=${APP_ENV^^}
  local DOMAINS=$(eval 'echo ${'"${APP_ENV_UPPER}"'_DOMAINS}')
  local DOMAIN_MAIN=$(eval 'echo ${'"${APP_ENV_UPPER}"'_DOMAIN_MAIN}')
  local APP_PATH_ROOT="$(realpath .)/"

  _wexLog "Preparing global site configuration"
  local APP_CONFIG_FILE_CONTENT=$(cat "${WEX_FILEPATH_REL_CONFIG}")

  APP_CONFIG_FILE_CONTENT+="\n\n# Auto generated"
  APP_CONFIG_FILE_CONTENT+="\nAPP_NAME=${NAME}"
  APP_CONFIG_FILE_CONTENT+="\nCOMPOSE_PROJECT_NAME=${NAME}_${APP_ENV}"
  APP_CONFIG_FILE_CONTENT+="\nAPP_NAME_INTERNAL=${NAME}_${APP_ENV}"
  APP_CONFIG_FILE_CONTENT+="\nAPP_ENV=${APP_ENV}"
  APP_CONFIG_FILE_CONTENT+="\nAPP_PATH_ROOT=${APP_PATH_ROOT}"
  APP_CONFIG_FILE_CONTENT+="\nAPP_PATH_WEX=${APP_PATH_ROOT}${WEX_DIR_APP_DATA}"
  APP_CONFIG_FILE_CONTENT+="\nSTARTED=${STARTED}"
  APP_CONFIG_FILE_CONTENT+="\nWEX_DIR_PROXY=${WEX_DIR_PROXY}"
  APP_CONFIG_FILE_CONTENT+="\n\n# Environment related"
  APP_CONFIG_FILE_CONTENT+="\nDOMAIN_MAIN=${DOMAIN_MAIN}"
  APP_CONFIG_FILE_CONTENT+="\nDOMAINS=${DOMAINS}"
  APP_CONFIG_FILE_CONTENT+="\nHOST_IP=$(wex-exec system/ip)"
  APP_CONFIG_FILE_CONTENT+="\nEMAIL=$(eval 'echo ${'"${APP_ENV_UPPER}"'_EMAIL}')"

  APP_CONFIG_FILE_CONTENT+="\n\n# User"

  local USER_UID=$(id -u "${USER}")
  # Current user is root, so uid is 0.
  if [ "${USER_UID}" = "0" ]; then
    USER_UID=${SUDO_UID}
  fi

  APP_CONFIG_FILE_CONTENT+='\nAPP_USER_UID='${USER_UID}

  _wexLog "Writing config file content"
  sudo -u "${USER}" printf "${APP_CONFIG_FILE_CONTENT}\n" | tee "${WEX_FILEPATH_REL_CONFIG_BUILD}" >/dev/null

  _configWritePorts

  _wexLog "Calling config hooks"
  wex-exec app::hook/exec -c=appConfig

  # In case we are on non unix system.
  wex-exec file/convertLinesToUnix -f="${WEX_FILEPATH_REL_CONFIG_BUILD}" &>/dev/null

  printf "\n" >>"${WEX_FILEPATH_REL_CONFIG_BUILD}"
  wex-exec app::config/addTitle -t="Compose files\n"

  _wexLog "Importing global app config variables"
  printf "\n" >>"${WEX_FILEPATH_REL_CONFIG_BUILD}"
  cat "${WEX_DIR_TMP}app-config" >>"${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Create docker-compose.build.yml
  _wexLog "Building ${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}"
  wex-exec app::app/compose -c=config | tee "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" >/dev/null
}

_configWritePorts() {
  local SERVICES=($(wex-exec app::services/list))
  local PORT_CURRENT=1001

  # Assign free ports.
  for SERVICE in ${SERVICES[@]}; do
    local VAR_NAME=SERVICE_PORT_$(wex-exec string/toScreamingSnake -t="${SERVICE}")

    # Avoid used ports.
    while [[ " ${PORTS_USED_ARRAY[@]} " =~ " ${PORT_CURRENT} " ]]; do
      ((PORT_CURRENT++))
    done

    # Assign port to variable
    wex-exec app::config/setValue -k="${VAR_NAME}" -v="${PORT_CURRENT}" -vv

    if [ "${PORTS_USED_CURRENT}" != '' ]; then
      PORTS_USED_CURRENT+=${SEPARATOR}
    fi

    PORTS_USED_CURRENT+=${PORT_CURRENT}

    ((PORT_CURRENT++))
  done
}
