#!/usr/bin/env bash

configSetValueArgs() {
  _ARGUMENTS=(
   'key k "Target key to change" true'
   'separator s "Separator like space or equal sign, default space" false " "'
   'ignore_duplicates i "Do not check if variable exists or is commented" false false'
   'value v "New value" true'
  )
}

configSetValue() {
  wex config/setValue -f="${WEX_FILEPATH_REL_CONFIG_BUILD}" -s="=" -k="${KEY}" -i="${IGNORE_DUPLICATES}" -v="${VALUE}"
}
