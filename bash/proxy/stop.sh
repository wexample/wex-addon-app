#!/usr/bin/env bash

proxyStopArgs() {
  _AS_NON_SUDO=false
}

proxyStop() {
  # Stop all sites
  if [ -f "${WEX_PROXY_APPS_REGISTRY}" ];then
    wex app::apps/stop
  fi

  cd "${WEX_DIR_PROXY}"

  wex app::app/stop

  # Remove temp files
  echo "" > "${WEX_PROXY_APPS_REGISTRY}"
}
