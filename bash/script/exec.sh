#!/usr/bin/env bash

scriptExecArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'command c "Command name, ex : "command" to execute ci/command.sh" true'
    'args a "Arguments to pass to script, ex "foo=bar"" false'
  )
}

scriptExec() {
  _wexAppGoTo .

  local FILE_PATH="${WEX_DIR_APP_DATA}script/${COMMAND}.sh"

  # Execute custom script for site.
  if [ -f "${FILE_PATH}" ];then
    . "${FILE_PATH}" ${ARGS}
  fi
}
