#!/usr/bin/env bash

dbGoArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Enter into database management CLI"
}

dbGo() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  local DB_GO_COMMAND=$(wex-exec service/exec -c=dbGo)

  wex-exec app/exec -n="${DB_CONTAINER}" -c="${DB_GO_COMMAND} ${MYSQL_DB_NAME}"
}
