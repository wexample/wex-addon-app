#!/usr/bin/env bash

appIssetArgs() {
  _DESCRIPTION="Return true if we are in an app directory"
  _ARGUMENTS=(
    'dir d "Starting directory" false'
  )
}

appIsset() {
  if [[ "$(wex app::app/locate -d="${DIR}")" != "" ]]; then
    echo "true"
  else
    echo "false"
  fi
}
