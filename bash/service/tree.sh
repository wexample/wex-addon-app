#!/usr/bin/env bash

serviceTreeArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'services s "Services list, comma separated" true'
  )
}

serviceTree() {
  local SERVICES_LIST=($(echo ${SERVICES} | tr "," "\n"))
  local SERVICES_JOINED=''

  for SERVICE in "${SERVICES_LIST[@]}"
  do
    if [ "${SERVICES_JOINED}" != "" ];then
      SERVICES_JOINED+=','
    fi

    SERVICES_JOINED+=${SERVICE}

    local SERVICE_CONFIG="$(wex-exec app::service/dir -s="${SERVICE}")${WEX_FILE_SERVICE_CONFIG}"

    if [ -f "${SERVICE_CONFIG}" ];then
      local DEPENDENCIES=false

      # Load conf file.
      . "${SERVICE_CONFIG}"
      if [ "${DEPENDENCIES}" != "false" ];then

        SERVICES_JOINED+=','$(wex-exec service/tree -s=${DEPENDENCIES})
      fi
    fi
  done

  # Remove duplicates
  SERVICES_JOINED=$(echo "${SERVICES_JOINED}" | tr ',' '\n' | sort -u | tr '\n' ' ' | sed 's/ *$//g' | tr ' ' ',')

  echo "${SERVICES_JOINED}"
}
