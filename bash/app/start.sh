#!/usr/bin/env bash

appStartArgs() {
  _ARGUMENTS=(
    'clear_cache cc "Clear all caches" false'
    'only o "Stop all other running sites before" false'
    'port p "Port for accessing site, only allowed if not already defined" false'
  )
}

appStart() {
  # Stop other sites.
  if [ "${ONLY}" != "" ];then
    wex apps/stop
  fi
  
  # Create env file.
  if [ ! -f .env ];then
    if [ "$(wex prompt/yn -q="Missing .env file, would you like to create it ?")" = true ];then
      local ALLOWED_ENV="${WEX_APPS_ENVIRONMENTS[*]}";
      ALLOWED_ENV=$(wex array/join -a="${ALLOWED_ENV}" -s=",")

      # Ask user
      wex prompt/choice -c="${ALLOWED_ENV}" -q="Choose env name"

      SITE_ENV=$(wex prompt/choiceGetValue)

      echo "SITE_ENV=${SITE_ENV}" > .env
    else
      _wexLog "Starting aborted"
      return
    fi
  fi
  echo "starting..."
}