#!/usr/bin/env bash

dbDumpArgs() {
  _ARGUMENTS=(
    'filename f "Dump file name" false'
    'tag t "Tag name append as a suffix" false'
  )
}

dbDump() {
  local DUMP_FILE_NAME

  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Filename is specified
  if [ "${FILENAME}" != "" ];then
    DUMP_FILE_NAME=${FILENAME}
  else
    # Build dump name.
    local DUMP_FILE_NAME
    DUMP_FILE_NAME=${APP_ENV}'-'${DB_NAME_MAIN}"-"$(wex date/timeFileName)
    if [ "${TAG}" != "" ];then
      DUMP_FILE_NAME+="-"${TAG}
    fi
  fi

  wex hook/exec -c=dbDump -a="${DUMP_FILE_NAME}"
}
