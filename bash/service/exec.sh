#!/usr/bin/env bash

serviceExecArgs() {
  _ARGUMENTS=(
    'command c "Command name" true'
    'service_only s "Service only" false'
    'service_only_forced sf "Force to use service even not registered into site config" false'
    'data d "Data" false'
    'parse p "Parse output variables" false'
    'args a "Arguments to pass to script" false'
  )
}

serviceExec() {
  _wexAppGoTo .

  # Service name specified.
  if [ "${SERVICE_ONLY}" != "" ] && [ "${SERVICE_ONLY_FORCED}" = "true" ];then
    local SERVICES=("${SERVICE_ONLY}")
  else
    local SERVICES=($(wex app::services/list))
  fi

  COMMAND_UC=$(wex default::string/toPascal -t="${COMMAND}")

  for SERVICE in ${SERVICES[@]}
  do
    if [ "${SERVICE_ONLY}" == "" ] || [ "${SERVICE_ONLY}" == "${SERVICE}" ];then
      local SERVICE_DIR=$(wex service/dir -s="${SERVICE}")
      local SERVICE_FILE_SCRIPT="${SERVICE_DIR}hooks/${COMMAND}.sh"

      if [ -f "${SERVICE_FILE_SCRIPT}" ];then
        . "${SERVICE_FILE_SCRIPT}"
        local METHOD=$(wex string/toCamel -t=${SERVICE})${COMMAND_UC}

        ${METHOD} ${DATA} "${ARGS}"
      fi;
    fi
  done
}
