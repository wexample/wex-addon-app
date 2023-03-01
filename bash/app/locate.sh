#!/usr/bin/env bash

appLocateArgs() {
  # shellcheck disable=SC2034
  _DESCRIPTION="Search into parent tree if current folder is in a wex project. Returns the wex project real path if found"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'app_dir ad "Application directory" false zz'
  )
}

appLocate() {
  local DIR_PREVIOUS
  local DIR_CURRENT
  local DIR_ORIGINAL
  local DIR_WEX

  DIR_CURRENT="${APP_DIR:-"$(realpath .)/"}"
  DIR_ORIGINAL=${DIR_CURRENT}

  while [ "${DIR_CURRENT}" != "${DIR_PREVIOUS}" ]; do
    DIR_WEX="${DIR_CURRENT}/${WEX_DIR_APP_DATA}"

    # Config found.
    if [ -f "${DIR_WEX}${WEX_FILE_APP_ENV}" ]; then
      echo "${DIR_CURRENT}/"
      return
    fi

    DIR_PREVIOUS=${DIR_CURRENT}
    DIR_CURRENT=$(realpath "${DIR_CURRENT}/../")
  done

  cd "${DIR_ORIGINAL}"
}
