#!/usr/bin/env bash

appStopArgs() {
  _NEEDS_APP_LOCATION=true
  _ARGUMENTS=(
    "${WEX_APP_ARG_APP_DIR}"
  )
  _AS_NON_SUDO=false
  _DESCRIPTION="Stops app"
}

appStop() {
  # Already stopped
  if [ "$(wex-exec app::app/started -ic)" = false ]; then
    return
  fi
  # Execute services scripts if exists
  wex-exec app::hook/exec -c=appStop
  # Write config.
  wex-exec app::config/setValue -k=STARTED -v=false -vv
  # Use previously generated yml file.
  docker compose -f "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" --env-file "${WEX_FILEPATH_REL_CONFIG_BUILD}" down
  # Reload file
  wex-exec app::apps/reload
  # Rebuild hosts in wex registry.
  wex-exec app::hosts/update
  # Rebuild hosts global /etc/hosts.
  wex-exec app::hosts/updateLocal
  # Execute services scripts if exists
  wex-exec hook/exec -c=appStopped
}
