#!/usr/bin/env bash

proxyAppConfig() {
  _wexLog "Proxy : configuration"
  printf "\n" >>"${WEX_FILEPATH_REL_CONFIG_BUILD}"

  local WEX_SERVER_PORT_PUBLIC

  _wexLog "Proxy : port detection"
  if [ "${WEX_SERVER_PORT_PUBLIC}" = "" ]; then
    local WEX_SERVER_PORT_PUBLIC
    # For macos, use 4242 as default port.
    WEX_SERVER_PORT_PUBLIC=$([[ "$(uname -s)" == Darwin ]] && echo 4242 || echo 80)
  fi

  # Check if a process is using port 80 (or given port)
  local PROCESSES
  PROCESSES=$(sudo netstat -tulpn | grep ":${WEX_SERVER_PORT_PUBLIC}")

  if [ "${PROCESSES}" != "" ]; then
    _wexError "A process is already running on port ${WEX_SERVER_PORT_PUBLIC}"
    echo "${PROCESSES}"

    wex-exec var/set -n=PROXY_ERROR -v=ERR_PORT_NOT_AVAILABLE
    exit
  fi

  _wexLog "Proxy : using port ${WEX_SERVER_PORT_PUBLIC}"

  local WEX_DOCKER_MACHINE_IP
  local WEX_IMAGES_VERSION

  WEX_DOCKER_MACHINE_IP=$(wex-exec docker::docker/ip)
  WEX_IMAGES_VERSION=$(wex-exec core/version)

  wex-exec app::config/setValue -k=WEX_DOCKER_MACHINE_IP -v="${WEX_DOCKER_MACHINE_IP}"
  wex-exec app::config/setValue -k=WEX_DIR_TMP -v="${WEX_DIR_TMP}"
  wex-exec app::config/setValue -k=WEX_IMAGES_VERSION -v="${WEX_IMAGES_VERSION}"
  wex-exec app::config/setValue -k=WEX_SERVER_PORT_PUBLIC -v="${WEX_SERVER_PORT_PUBLIC}"
}
