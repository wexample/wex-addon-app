#!/usr/bin/env bash

dbRestore() {
  if [ "$(wex app::app/started -ic)" = "false" ]; then
    _wexLog "App not started"
    return
  fi

  local DUMPS=($(wex hook/exec -c=dbDumpsList))
  DUMPS=$(wex array/join -a="${DUMPS[*]}" -s=",")

  if [ -z "${DUMPS}" ]; then
    _wexLog "No dump found."
    return
  fi

  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  wex prompt::prompt/choice -c="${DUMPS}" -q="Please select a dump to restore" -d="${#DUMPS[*]}"
  DUMP=$(wex prompt::prompt/choiceGetValue)

  local DUMP_PATH=${WEX_DIR_APP_DATA}${DB_CONTAINER}/dumps/${DUMP}

  if [ ! -f "${DUMP_PATH}" ]; then
    _wexLog "File not found : ${DUMP_PATH}"
    return
  fi

  wex db/unpack -d="${DUMP_PATH}"

  # Remove file extension in any case.
  local DUMP_FILE_NAME=$(basename "${DUMP%.*}")

  _wexLog "Restoring..."
  wex hook/exec -c=dbRestore -a="${DUMP_FILE_NAME}"

  _wexLog "Restoration complete"
}
