#!/usr/bin/env bash

dbDumpArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Create a database dump"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'filename f "Dump file name" false'
    'tag t "Tag name append as a suffix" false'
  )
}

dbDump() {
  if [ "$(wex-exec app::app/started -ic)" = "false" ]; then
    return
  fi

  local DUMP_FILE_NAME

  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Filename is specified
  if [ "${FILENAME}" != "" ]; then
    DUMP_FILE_NAME=${FILENAME}
  else
    # Build dump name.
    local DUMP_FILE_NAME
    DUMP_FILE_NAME=${APP_ENV}'-'${APP_NAME}"-"$(wex-exec date/timeFileName)
    if [ "${TAG}" != "" ]; then
      DUMP_FILE_NAME+="-"${TAG}
    fi
  fi

  # Create dump file.
  _wexLog "Exporting dump"
  local DUMP_PATH=$(wex-exec hook/exec -c=dbDump -a="${DUMP_FILE_NAME}")

  # Zip dump file.
  _wexLog "Creating zip file"
  local DIR_CURRENT
  DIR_CURRENT="$(realpath .)"

  cd "$(dirname "${DUMP_PATH}")"
  zip -r "${DUMP_FILE_NAME}.zip" "$(basename ${DUMP_PATH})"

  cd "${DIR_CURRENT}"

  # Cleaning up
  wex-exec file/remove -f="${DUMP_PATH}"

  _wexLog "Output dump : ${DUMP_FILE_NAME}.zip"
}
