#!/usr/bin/env bash

appStartArgs() {
  _ARGUMENTS=(
    'clear_cache cc "Clear all caches" false'
    'only o "Stop all other running sites before" false'
    'port p "Port for accessing site, only allowed if not already defined" false'
    'dir d "Application directory" false'
  )
}

appStart() {
  wex prompt::prompt/progress -p=0 -s="Preparing"

  # Stop other sites.
  if [ "${ONLY}" != "" ];then
    wex app::apps/stop
  fi

  wex prompt::prompt/progress -p=5 -s="Check location"

  local LOCATION=$(wex app::app/locate -d="${DIR}")
  # Create env file.
  if [ "${LOCATION}" = "" ];then
    if [ "$(wex prompt::prompt/yn -q="No .wex/.env file, would you like to create it ?")" = true ];then
      LOCATION="$(realpath .)/"
      FILE_ENV="${LOCATION}${WEX_FILE_APP_FOLDER}/${WEX_FILE_APP_ENV}"

      local ALLOWED_ENV="${WEX_APPS_ENVIRONMENTS[*]}";
      ALLOWED_ENV=$(wex array/join -a="${ALLOWED_ENV}" -s=",")

      # Ask user
      wex prompt::prompt/choice -c="${ALLOWED_ENV}" -q="Choose env name"

      SITE_ENV=$(wex prompt::prompt/choiceGetValue)

      # Creates .wex
      mkdir -p "$(dirname "${FILE_ENV}")"

      echo "SITE_ENV=${SITE_ENV}" > "${FILE_ENV}"
      _wexLog "Created .env file for env ${SITE_ENV}"
    else
      _wexLog "Starting aborted"
      return
    fi
  fi

  # Go to proper location
  cd "${LOCATION}"

  wex config/load

  # Prepare files
  wex prompt::prompt/progress -p=10 -s="Converting files"
  wex file/convertLinesToUnix -f=.env &> /dev/null
  wex file/convertLinesToUnix -f=.wex &> /dev/null

  # Write new config,
  # it will also export config variables
  wex prompt::prompt/progress -p=15 -s="Writing configuration"
  wex config/write -s

  wex prompt::prompt/progress -p=100 -s="Started"
}