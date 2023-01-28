#!/usr/bin/env bash

proxyStartArgs() {
  _ARGUMENTS=(
    'port p "Port for accessing sites" false'
  )
  _AS_SUDO=false
  _AS_SUDO_RUN=true
}

proxyStart() {
  # Check if running.
  if [ "$(wex app::proxy/started -ic)" = true ]; then
    return;
  fi

  if [ ! -d "${WEX_DIR_PROXY}" ];then
    mkdir -p "${WEX_DIR_PROXY}"
  fi

  ${WEX_CHOWN_NON_SUDO_COMMAND} -R "${WEX_DIR_PROXY}"
  cd "${WEX_DIR_PROXY}"

  if [ "${PORT}" = "" ];then
    local PORT
    # For macos, use 4242 as default port.
    PORT=$([[ "$(uname -s)" == Darwin ]] && echo 4242 || echo 80)
  fi

  # Check if a process is using port 80 for proxy (or given port)
  local PROCESSES
  PROCESSES=$(sudo netstat -tulpn | grep ":${PORT}")
  if [ "$(wex system::port/used -p="${PORT}")" = "true" ];then
    _wexError "A process is already running on proxy port ${PORT}"
    sudo netstat -tunlp | grep ":${PORT} "
    exit
  fi

  if [ ! -d "${WEX_DIR_PROXY}.wex" ];then
    wex app::prompt/chooseEnv -q="Choose env name for proxy server"

    local NEW_ENV
    NEW_ENV=$(wex prompt::prompt/choiceGetValue)

    if [ -z "${NEW_ENV}" ]; then
      exit
    fi

    wex app::app/init -s=proxy -e="${NEW_ENV}" -n="${WEX_PROXY_NAME}" --git=false
  fi

  export WEX_SERVER_PORT_PUBLIC=${PORT}

  _wexLog "Starting proxy app"
  wex app::app/start

  # Wait starting.
  _wexLog "Waiting for proxy start..."
  sleep 5
}
