#!/usr/bin/env bash

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
