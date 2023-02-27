#!/usr/bin/env bash

proxyStopArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Stops the local reverse proxy web server"
  _AS_NON_SUDO=false
}

proxyStop() {
  # Stop all sites
  if [ -f "${WEX_PROXY_APPS_REGISTRY}" ]; then
    wex-exec app::apps/stop
  fi

  cd "${WEX_DIR_PROXY}"

  wex-exec app::app/stop

  # Remove temp files
  echo "" >"${WEX_PROXY_APPS_REGISTRY}"
}
