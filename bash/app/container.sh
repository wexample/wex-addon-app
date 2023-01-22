#!/usr/bin/env bash

appContainerArgs() {
  _ARGUMENTS=(
    'container c "User container" true'
  )
}

appContainer() {
  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

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