#!/usr/bin/env bash

serviceRemoveArgs() {
  _ARGUMENTS=(
    'service s "Service to remove" true'
  )
}

serviceRemove() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG}"

  if [ "${SERVICES}" != "" ];then
    # Split to array
    SERVICES=$(wex string/split -t=${SERVICES} -s=",")
    # One line
    SERVICES=$(echo ${SERVICES[@]})
    # Remove service
    SERVICES=$(wex array/remove -a="${SERVICES[*]}" -i="${SERVICE}")
    # Save joined.
    wex app::config/setValue -b -k=SERVICES -v="$(wex array/join -a="${SERVICES}" -s=",")"
  fi

  wex service/exec -s="${SERVICE}" -c=serviceRemove
}
