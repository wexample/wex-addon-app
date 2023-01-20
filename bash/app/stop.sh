#!/usr/bin/env bash

appStopArgs() {
  _AS_SUDO=false
  _AS_SUDO_RUN=true
}

appStop() {
  # Already stopped
  if [ "$(wex app::app/started -ic)" = false ];then
    return
  fi
  # Execute services scripts if exists
  wex app::hook/exec -c=appStop
  # Write config file, indicates started=stop
  wex app::config/write -s=false -nr
  # Use previously generated yml file.
  docker compose -f "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" --env-file "${WEX_FILEPATH_REL_CONFIG_BUILD}" down
  # Reload file
  wex app::apps/cleanup
  # Rebuild hosts in wex registry.
  wex app::hosts/update
  # Rebuild hosts global /etc/hosts.
  wex app::hosts/updateLocal
  # Execute services scripts if exists
  wex hook/exec -c=appStopped
}
