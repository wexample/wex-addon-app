#!/usr/bin/env bash

appIssetArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _DESCRIPTION="Return true if we are in an app directory"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'dir d "Starting directory" false'
    'error e "Display error message if false" false'
  )
}

appIsset() {
  _wexAppGoTo "${DIR:-.}"

  if [ "$(wex-exec app::app/locate -d="${DIR}")" != "" ]; then
    echo "true"
  else
    if [ "${ERROR}" = "true" ]; then
      _wexError "No app found"
      exit
    else
      echo "false"
    fi
  fi
}
