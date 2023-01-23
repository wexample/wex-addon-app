#!/usr/bin/env bash

dbRestore() {
  if [ "$(wex app::app/started -ic)" = "false" ];then
    return
  fi

  local DUMPS=($(wex hook/exec -c=dbDumpsList))
  DUMPS=$(wex array/join -a="${DUMPS[*]}" -s=",")

  wex prompt::prompt/choice -c="${DUMPS}" -q="Please select a dump to restore" -d="${#DUMPS[*]}"
  DUMP=$(wex prompt::prompt/choiceGetValue)

  wex hook/exec -c=dbRestore -a="${DUMP}"
}
