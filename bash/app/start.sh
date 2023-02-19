#!/usr/bin/env bash

appStartArgs() {
  _ARGUMENTS=(
    'clear_cache cc "Clear all caches" false'
    'only o "Stop all other running sites before" false'
    'port p "Port for accessing site, only allowed if not already defined" false'
    'dir d "Application directory" false'
    'user u "Owner of application files" false false'
  )
  _AS_NON_SUDO=false
}

appStart() {
  if [ -f "${WEX_FILEPATH_REL_CONFIG_BUILD}" ];then
    . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

    if [ "${STARTED}" = "true" ] && [[ $(wex app/started) == true ]];then
      _wexLog "App already running"
      return
    fi
  fi

  wex prompt::prompt/progress -nl -p=0 -s="Preparing"

  # Stop other sites.
  if [ "${ONLY}" != "" ];then
    wex app::apps/stop
  fi

  wex prompt::prompt/progress -nl -p=10 -s="Check location"

  local DIR
  DIR=$(wex app::app/locate -d="${DIR}")
  # Create env file.
  if [ "${DIR}" = "" ];then
    if [ "$(wex prompt::prompt/yn -q="No .wex/.env file, would you like to create it ?")" = true ];then
      local APP_ENV;

      DIR="$(realpath .)/"
      FILE_ENV="${DIR}${WEX_DIR_APP_DATA}${WEX_FILE_APP_ENV}"

      wex app::prompt/chooseEnv

      APP_ENV=$(wex prompt::prompt/choiceGetValue)

      if [ -z "$APP_ENV" ]; then
        exit
      fi

      # Creates .wex
      mkdir -p "$(dirname "${FILE_ENV}")"

      echo "APP_ENV=${APP_ENV}" > "${FILE_ENV}"
      _wexLog "Created .env file for env ${APP_ENV}"
    else
      _wexLog "Starting aborted"
      return
    fi
  fi

  if [ "$(wex app::app/started -d="${DIR}")" = "true" ];then
    _wexLog "App already running"
    _appStartSuccess

    return;
  fi

  local IS_PROXY_SERVER
  IS_PROXY_SERVER=$(wex service/used -s=proxy)

  # Current site is not the server itself.
  if [ "${IS_PROXY_SERVER}" = false ];then
    wex prompt::prompt/progress -nl -p=30 -s="Check proxy"

    # The server is not running.
    if [ "$(wex app::proxy/started)" = false ];then
      _wexLog "Starting wex server"
      _appStartProxyAndRetry "${PORT}" "${USER}"
      return
    # The server is running.
    else
      # Asked port is not the same as currently used.
      if [[ $(_appProxyNeedsRestart) == true ]];then
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
          _appStartProxyAndRetry "${PORT}" "${USER}"
          return
        fi
      fi
    fi
  fi

  # Go to proper location
  _wexAppGoTo "${DIR:-.}" && . "${WEX_FILEPATH_REL_CONFIG}"

  . "${WEX_FILEPATH_REL_APP_ENV}"

  if [[ "${USER}" == false ]];then
    USER="${WEX_RUNNER_USERNAME}"
  else
    USER="nobody"
  fi

  _wexLog "Using user ${USER}:${USER}"
  sudo chown -R "${USER}:${USER}" .
  sudo chmod -R g+w .

  # Prepare files
  wex prompt::prompt/progress -nl -p=40 -s="Converting files"
  wex file/convertLinesToUnix -f="${WEX_FILE_APP_ENV}" &> /dev/null
  wex file/convertLinesToUnix -f="${WEX_DIR_APP_DATA}" &> /dev/null

  # Write new config,
  # it will also export config variables
  wex prompt::prompt/progress -nl -p=50 -s="Writing configuration"
  wex app::config/write -s -u="${USER}"

  if [ ! -s "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" ]; then
     _wexError "Unable to write ${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" "Try to execute wex config/write to check any write error."
     exit
  fi

  wex prompt::prompt/progress -nl -p=60 -s="Registering app"
  # Reload sites will clean up list.
  wex apps/reload
  # Add new site.
  echo -e "\n${DIR}" | tee -a "${WEX_PROXY_APPS_REGISTRY}" > /dev/null

  # Load app env.
  . "${WEX_FILEPATH_REL_APP_ENV}"

  # Rebuild hosts in wex registry.
  wex app::hosts/update

  local OPTIONS=''
  if [ "${CLEAR_CACHE}" = true ];then
    OPTIONS=' --build'
  fi

  local OPTIONS_SERVICES
  OPTIONS_SERVICES=$(wex app::service/exec -c=appStartOptions)
  if [ "${OPTIONS_SERVICES}" != "" ];then
    OPTIONS+="${OPTIONS_SERVICES}"
  fi

  wex prompt::prompt/progress -nl -p=70 -s="Starting container"
  # Use previously generated yml file.
  docker compose -f "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" --env-file "${WEX_FILEPATH_REL_CONFIG_BUILD}" up -d ${OPTIONS}

  wex prompt::prompt/progress -nl -p=80 -s="Updating permission"
  wex app::app/perms

  wex prompt::prompt/progress -nl -p=85 -s="Serving app"
  wex app::app/serve

  _appStartSuccess
}

_appProxyNeedsRestart() {
    # Load server config.
    . "${WEX_DIR_PROXY}${WEX_FILEPATH_REL_CONFIG_BUILD}"

    # Asked port is not the same as currently used.
    if [ "${PORT}" != "" ] && [ "${PORT}" != "${WEX_SERVER_PORT_PUBLIC}" ];then
      echo true
    else
      echo false
    fi
}

# Start server on the given port number.
_appStartProxyAndRetry() {
  local ARGS
  local CURRENT_DIR
  local PORT=${1}
  local USER=${2}

  # Cache overridden vars.
  ARGS=${WEX_ARGUMENTS}
  CURRENT_DIR=$(realpath ./)

  # Server must be started.
  wex app::proxy/start -n -p="${PORT}" -u="${USER}"

  # Relaunch manually to be sure to keep given arguments
  cd "${CURRENT_DIR}" || return
  wex app::app/start "${ARGS}"
}

_appStartSuccess() {
  wex prompt::prompt/progress -nl -p=90 -s="Check first initialization"

  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  if [ "${APP_INITIALIZED}" != true ]; then
    wex prompt::prompt/progress -nl -p=95 -s="Initializing first app launch..."
    wex app::hook/exec -c=appFirstStartInit

    wex app::config/setValue -b -k=APP_INITIALIZED -v=true
  fi

  wex prompt::prompt/progress -nl -p=100 -s="Started"

  wex app::hook/exec -c=appStarted

  # No message for proxy server.
  if [ "${NAME}" = "${WEX_PROXY_NAME}" ];then
    return
  fi

  echo ""

  local DOMAINS=$(wex app::app/domains)
  if [ "${DOMAINS}" != "" ];then
    _wexMessage "Your site \"${NAME}\" is up in \"${APP_ENV}\" environment" "You can access to it on these urls : "

    for DOMAIN in ${DOMAINS[@]}
    do
      echo "      > http://${DOMAIN}:${WEX_SERVER_PORT_PUBLIC}"
    done;
  else
    _wexMessage "No domain associated with \"${APP_ENV}\" environment"
  fi

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