#!/usr/bin/env bash

appContainerArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Return the full name of a container"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'container c "User container" true'
    'dir d "Application directory" false'
  )
}

appContainer() {
  _wexAppGoTo "${DIR:-.}" && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Default container name.
  if [ "${CONTAINER}" = "" ]; then
    if [ "${MAIN_CONTAINER_NAME}" != "" ]; then
      CONTAINER=${MAIN_CONTAINER_NAME}
    else
      CONTAINER=web
    fi
  fi

  echo "${APP_NAME_INTERNAL}_${CONTAINER}"
}
