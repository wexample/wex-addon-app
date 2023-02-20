#!/usr/bin/env bash

configYmlArgs() {
  _ARGUMENTS=(
    'file_compose_yml f "Docker compose file" false'
    'dir d "Site directory" false'
  )
}

configYml() {
  # Allow specified file
  if [ "${FILE_COMPOSE_YML}" = "" ]; then
    FILE_COMPOSE_YML=$(wex-exec app::app/locate -d="${DIR}")${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}
  fi;

  if [ ! -f "${FILE_COMPOSE_YML}" ];then
    return
  fi

  # Parse yml file built by docker compose.
  wex-exec language::yml/parseFile -f="${FILE_COMPOSE_YML}"
}
