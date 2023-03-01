#!/usr/bin/env bash

serviceRemoveArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Remove a script from at. Just remove config entry, do not modify other settings files"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'service s "Service to remove" true'
  )
}

serviceRemove() {
  . "${WEX_FILEPATH_REL_CONFIG}"

  if [ "${SERVICES}" != "" ]; then
    # Split to array
    SERVICES=$(wex-exec string/split -t=${SERVICES} -s=",")
    # One line
    SERVICES=$(echo ${SERVICES[@]})
    # Remove service
    SERVICES=$(wex-exec array/remove -a="${SERVICES[*]}" -i="${SERVICE}")
    # Save joined.
    wex-exec app::config/setValue -b -k=SERVICES -v="$(wex-exec array/join -a="${SERVICES}" -s=",")"
  fi

  wex-exec service/exec -s="${SERVICE}" -c=serviceRemove
}
