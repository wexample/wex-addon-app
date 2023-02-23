#!/usr/bin/env bash

serviceExecArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'command c "Command name" true'
    'service_only s "Service only" false'
    'service_only_forced sf "Force to use service even not registered into site config" false'
    'data d "Data" false'
    'parse p "Parse output variables" false'
    'args a "Arguments to pass to script" false'
    'test t "Execute test instead hook" false false'
  )
}

serviceExec() {
  _wexAppGoTo .

  # Service name specified.
  if [ "${SERVICE_ONLY}" != "" ] && [ "${SERVICE_ONLY_FORCED}" = "true" ];then
    local SERVICES=("${SERVICE_ONLY}")
  else
    local SERVICES=($(wex-exec app::services/list))
  fi

  local COMMAND_UC
  COMMAND_UC=$(wex-exec default::string/toPascal -t="${COMMAND}")

  for SERVICE in ${SERVICES[@]}
  do
    if [ "${SERVICE_ONLY}" = "" ] || [ "${SERVICE_ONLY}" = "${SERVICE}" ];then
      local SERVICE_DIR=$(wex-exec service/dir -s="${SERVICE}")
      local SERVICE_FILE_SCRIPT
      local METHOD
      METHOD=$(wex-exec string/toCamel -t="${SERVICE}")${COMMAND_UC}

      if [ "${TEST}" = "true" ];then
        SERVICE_FILE_SCRIPT="${SERVICE_DIR}tests/${COMMAND}.sh"
        METHOD+=Test

        # Tests does not support missing files.
        if [ ! -f "${SERVICE_FILE_SCRIPT}" ];then
          _wexTestResultError "Missing test file : ${SERVICE_FILE_SCRIPT}"
          exit
        fi;
      else
        SERVICE_FILE_SCRIPT="${SERVICE_DIR}hooks/${COMMAND}.sh"
      fi

      if [ -f "${SERVICE_FILE_SCRIPT}" ];then
        . "${SERVICE_FILE_SCRIPT}"

        ${METHOD} ${DATA} "${ARGS}"
      fi;
    fi
  done
}
