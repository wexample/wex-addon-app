#!/usr/bin/env bash

proxyStartArgs() {
  _ARGUMENTS=(
    'no_recreate n "Do not recompose if already running" false'
    'port p "Port for accessing sites" false'
  )
  _AS_NON_SUDO=false
}

proxyStart() {
  # Check if running.
  if [ ! -z ${NO_RECREATE+x} ] && [ "$(wex app::proxy/started)" = true ]; then
    return;
  fi

  if [ ! -d "${WEX_DIR_PROXY}" ];then
    mkdir -p "${WEX_DIR_PROXY}"
  fi

  chmod -R 777 "${WEX_DIR_PROXY}"
  cd "${WEX_DIR_PROXY}"

  if [ ! -d "${WEX_DIR_PROXY}.wex" ];then
    wex app::app/init -s=proxy -n="${WEX_PROXY_NAME}" -e=prod --git=false
  fi

  _wexLog "Starting proxy app"
  wex app::app/start

  # Wait starting.
  _wexLog "Waiting proxy starts..."
  sleep 5
}
