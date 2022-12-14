#!/usr/bin/env bash

configWriteArgs() {
  _ARGUMENTS=(
    'started s "Set the site is started or not" false'
    'no_recreate nr "No recreate if files exists" false'
    'dir d "Application directory" false'
  )
}

configWrite() {
#  # No recreate.
#  if [ "${NO_RECREATE}" = true ] &&
#    [ -f "${WEX_WEXAMPLE_APP_DIR_TMP}config" ] &&
#    [ -f "${WEX_WEXAMPLE_APP_COMPOSE_BUILD_YML}" ];then
#
#    # TODO fix the config issue in globals.sh before enabling nested logs
#    #  _wexLog "App config file exists. No recreating."
#    return
#  fi

  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG}"

  _wexLog "Creating temporary folder : ${WEX_DIR_APP_TMP}"
    # Create temp dirs if not exists.
  mkdir -p "${WEX_DIR_APP_TMP}"

  if [ "${STARTED}" != true ];then
    STARTED=false
  fi;

  local APP_ENV
  APP_ENV=$(wex app::app/env)

  local APP_ENV_UPPER=${APP_ENV^^}
  local DOMAINS=$(eval 'echo ${'"${APP_ENV_UPPER}"'_DOMAINS}')
  local DOMAIN_MAIN=$(eval 'echo ${'"${APP_ENV_UPPER}"'_DOMAIN_MAIN}')

  _wexLog "Preparing global site configuration"
  local APP_CONFIG_FILE_CONTENT=""

  APP_CONFIG_FILE_CONTENT+="# Global"
  APP_CONFIG_FILE_CONTENT+="\nAPP_NAME=${NAME}"
  APP_CONFIG_FILE_CONTENT+="\nAPP_NAME_INTERNAL=${NAME}"_"${APP_ENV}"
  APP_CONFIG_FILE_CONTENT+="\nAPP_ENV=${APP_ENV}"
  APP_CONFIG_FILE_CONTENT+="\nAPP_PATH_ROOT=$(realpath .)/"
  APP_CONFIG_FILE_CONTENT+="\nSTARTED=${STARTED}"
  APP_CONFIG_FILE_CONTENT+="\nWEX_DIR_PROXY=${WEX_DIR_PROXY}"
  APP_CONFIG_FILE_CONTENT+="\n\n# Environment related"
  APP_CONFIG_FILE_CONTENT+="\nDOMAIN_MAIN=${DOMAIN_MAIN}"
  APP_CONFIG_FILE_CONTENT+="\nDOMAINS=${DOMAINS}"
  APP_CONFIG_FILE_CONTENT+="\nEMAIL=$(eval 'echo ${'"${APP_ENV_UPPER}"'_EMAIL}')"

  APP_CONFIG_FILE_CONTENT+="\n\n# User"

  local USER_UID=${UID}
  # Current user is root, so uid is 0.
  if [ "${USER_UID}" = "0" ];then
    USER_UID=${SUDO_UID}
  fi

  APP_CONFIG_FILE_CONTENT+='\nUSER_UID='${USER_UID}

  _wexLog "Writing config file content"
  printf "${APP_CONFIG_FILE_CONTENT}" | tee "${WEX_FILEPATH_REL_CONFIG_BUILD}" > /dev/null

  _wexLog "Calling config hooks"
  wex app::hook/exec -c=appConfig
  
  # In case we are on non unix system.
  wex file/convertLinesToUnix -f="${WEX_FILEPATH_REL_CONFIG_BUILD}" &> /dev/null

  # Create docker-compose.build.yml
  wex app::app/compose -c=config | tee "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" > /dev/null
}