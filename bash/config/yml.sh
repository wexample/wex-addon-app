#!/usr/bin/env bash

configYmlArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Parse docker compose yml file to extract values"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'file_compose_yml f "Docker compose file" false'
    'app_dir ad "Application directory" false'
  )
}

configYml() {
  # Allow specified file
  if [ "${FILE_COMPOSE_YML}" = "" ]; then
    FILE_COMPOSE_YML=$(wex-exec app::app/locate -d="${APP_DIR}")${WEX_FILEPATH_REL_COMPOSE_BUILD_YML}
  fi

  if [ ! -f "${FILE_COMPOSE_YML}" ]; then
    return
  fi

  # Parse yml file built by docker compose.
  wex-exec language::yml/parseFile -f="${FILE_COMPOSE_YML}"
}
