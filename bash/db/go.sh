#!/usr/bin/env bash

dbGo() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  local DB_GO_COMMAND=$(wex service/exec -c=dbGo)

  wex app/exec -n="${DB_CONTAINER}" -c="${DB_GO_COMMAND} ${MYSQL_DB_NAME}"
}
