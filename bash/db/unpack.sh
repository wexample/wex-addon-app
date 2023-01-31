#!/usr/bin/env bash

dbUnpackArgs() {
  _ARGUMENTS=(
    'dump d "Dump relative file name, might be a zip" false'
  )
}

dbUnpack() {
  if [[ -f ${DUMP} ]]; then
    DIR_CURRENT="$(realpath .)"
    cd $(dirname "${DUMP}")

    local DUMP_FILE_NAME
    DUMP_FILE_NAME=$(basename "${DUMP%.*}")

    # Not already extracted.
    if [ ! -d "${DUMP_FILE_NAME}" ] && [ ! -f "${DUMP_FILE_NAME}" ];then
      if [[ "${DUMP}" != *.zip ]]; then
        _wexLog "The dump ${DUMP} is not a zip file"
        return
      fi

      _wexLog "Database : Unpacking dump ${DUMP}"
      unzip "${DUMP_FILE_NAME}"
    fi

    cd "${DIR_CURRENT}"
  fi
}
