#!/usr/bin/env bash

appsStopArgs() {
  _DESCRIPTION="Stops all running apps, keep proxy alive"
}

appsStop() {
  _wexLog "Stopping all running apps..."

  if [ ! -f "${WEX_PROXY_APPS_REGISTRY}" ]; then
    return
  fi

  local CURRENT_DIR
  CURRENT_DIR=$(realpath ./)

  REGISTRY=$(cat "${WEX_PROXY_APPS_REGISTRY}")

  for SITE_PATH in ${REGISTRY[@]}; do
    # Avoid blank lines."
    if [ "$(wex-exec string/trim -s="${SITE_PATH}")" != "" ]; then
      # Keep wex_server alive.
      if [ "$(basename "${SITE_PATH}")" != "${WEX_PROXY_NAME}" ]; then
        cd "${SITE_PATH}"
        wex-exec app::app/stop
      fi
    fi
  done

  # Go back to original dir.
  cd "${CURRENT_DIR}"
}
