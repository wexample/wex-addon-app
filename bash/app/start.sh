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

  local DIR
  DIR=$(wex app::app/locate -d="${DIR}")
  # Create env file.
  if [ "${DIR}" = "" ];then
    if [ "$(wex prompt::prompt/yn -q="No .wex/.env file, would you like to create it ?")" = true ];then
      DIR="$(realpath .)/"
      FILE_ENV="${DIR}${WEX_DIR_APP_DATA}${WEX_FILE_APP_ENV}"

      local ALLOWED_ENV="${WEX_APPS_ENVIRONMENTS[*]}";
      ALLOWED_ENV=$(wex array/join -a="${ALLOWED_ENV}" -s=",")

      # Ask user
      wex prompt::prompt/choice -c="${ALLOWED_ENV}" -q="Choose env name"

      APP_ENV=$(wex prompt::prompt/choiceGetValue)

      # Creates .wex
      mkdir -p "$(dirname "${FILE_ENV}")"

      echo "APP_ENV=${APP_ENV}" > "${FILE_ENV}"
      _wexLog "Created .env file for env ${APP_ENV}"
    else
      _wexLog "Starting aborted"
      return
    fi
  fi

  local IS_PROXY_SERVER
  IS_PROXY_SERVER=$(wex service/used -s=proxy)

  # Current site is not the server itself.
  if [ "${IS_PROXY_SERVER}" = false ];then
    wex prompt::prompt/progress -p=10 -s="Check proxy"

    # The server is not running.
    if [ "$(wex app::proxy/started)" = false ];then
      _wexLog "Starting wex server"
      _appStartRetry ${PORT}
      return
    # The server is running.
    else
      # Load server config.
      . "${WEX_DIR_PROXY}${WEX_FILEPATH_REL_CONFIG_BUILD}"
      # Asked port is not the same as currently used.
      if [ "${PORT}" != "" ] && [ "${PORT}" != "${WEX_SERVER_PORT_PUBLIC}" ];then
        local APPS_COUNT=$(wex apps/list -c);
        # Ignore server itself.
        ((APPS_COUNT--))

        # There is unexpected running sites.
        if (( APPS_COUNT > 0 )); then
          _wexError "Unable to start apps on multiple ports" "Your wex server is running ${APPS_COUNT} app(s) on port ${WEX_SERVER_PORT_PUBLIC}" "Run the app on port ${WEX_SERVER_PORT_PUBLIC} or stop other apps"
          exit
        # Restart server with given new port number.
        else
          _wexMessage "Restarting wex server on port ${PORT}"
          wex app::proxy/stop
          _appStartRetry ${PORT}
          return
        fi
      fi
    fi
  fi

  # Go to proper location
  _wexAppGoTo ${DIR} && . "${WEX_FILEPATH_REL_CONFIG}"

  # Prepare files
  wex prompt::prompt/progress -p=15 -s="Converting files"
  wex file/convertLinesToUnix -f=.env &> /dev/null
  wex file/convertLinesToUnix -f=.wex &> /dev/null

  # Write new config,
  # it will also export config variables
  wex prompt::prompt/progress -p=20 -s="Writing configuration"
  wex app::config/write -s

  # Reload sites will clean up list.
  wex apps/cleanup
  # Add new site.
  echo -e "\n"${DIR} | tee -a ${WEX_PROXY_APPS_REGISTRY} > /dev/null

  local OPTIONS=''
  if [ "${CLEAR_CACHE}" = true ];then
    OPTIONS=' --build'
  fi
  
  # Use previously generated yml file.
  docker-compose -f "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" up -d ${OPTIONS}

  wex prompt::prompt/progress -p=100 -s="Started"

  if [ "${APP_ENV}" = "local" ];then
    echo ""
    echo "      You are in a local environment, so you might want"
    echo "      to run now some of this dev methods :"
    echo "        wex watcher/start"
    echo "        wex app/serve"
    echo "        wex app/go"
    echo ""
  fi
}

# Start server on the given port number.
_appStartRetry() {
  local ARGS
  local CURRENT_DIR
  local PORT=${1}

  # Cache overridden vars.
  ARGS=${WEX_ARGUMENTS}
  CURRENT_DIR=$(realpath ./)

  # Server must be started.
  wex app::proxy/start -n -p="${PORT}"

  # Relaunch manually to be sure to keep given arguments
  cd "${CURRENT_DIR}" || return
  wex app::app/start "${ARGS}"
}