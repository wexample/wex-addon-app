#!/usr/bin/env bash

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
  docker-compose -f "${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}" down
  # Reload file
  wex app::apps/update
  # Rebuild hosts
  wex app::hosts/update
  # Execute services scripts if exists
  wex hook/exec -c=appStopped
}
