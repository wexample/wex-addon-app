#!/usr/bin/env bash

appConfigArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'key k "Key of config param to get" true'
    'dir_site d "Root site directory" false'
  )
}

appConfig() {
  if [ -z "${DIR_SITE+x}" ]; then
    DIR_SITE=./
  fi;

  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG}"

  # Uppercase key.
  eval 'echo ${'"${KEY^^}"'}'
}
