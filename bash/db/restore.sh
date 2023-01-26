#!/usr/bin/env bash

dbRestore() {
  if [ "$(wex app::app/started -ic)" = "false" ];then
    return
  fi

  local DUMPS=($(wex hook/exec -c=dbDumpsList))
  DUMPS=$(wex array/join -a="${DUMPS[*]}" -s=",")

  wex prompt::prompt/choice -c="${DUMPS}" -q="Please select a dump to restore" -d="${#DUMPS[*]}"
  DUMP=$(wex prompt::prompt/choiceGetValue)

  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"
  wex db/unpack -d="${WEX_DIR_APP_DATA}${DB_CONTAINER}/dumps/${DUMP}"

  local DUMP_FILE_NAME
  DUMP_FILE_NAME=$(basename "${DUMP%.*}")

  wex hook/exec -c=dbRestore -a="${DUMP_FILE_NAME}"
}
