#!/usr/bin/env bash

remoteGoArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _DESCRIPTION="SSH connect to remote environment"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'env e "Remote environment name" false'
  )
}

remoteGo() {
  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  _wexMessage "Your are switching environment to ${ENV^^}."

  local REMOTE_HOST=$(wex app::env/getVar -n=SERVER_MAIN -e="${ENV}")
  local REMOTE_USERNAME=$(wex app::env/getVar -n=SSH_USERNAME -e="${ENV}")

  REMOTE_USERNAME=${REMOTE_USERNAME:-$(whoami)}

  ENV=$(echo "${ENV}" | tr '[:upper:]' '[:lower:]')
  local REMOTE_PATH="/var/www/${ENV}/${APP_NAME}"
  ssh -t ${REMOTE_USERNAME}@${REMOTE_HOST} "[ -d $REMOTE_PATH ] && cd $REMOTE_PATH && exec \$SHELL -i"

  _wexMessage "You're back in ${APP_ENV^^} environment."
}
