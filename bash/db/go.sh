#!/usr/bin/env bash

dbGo() {
  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  local DB_GO_COMMAND=$(wex service/exec -c=dbGo -s="maria-10")
  wex app/exec -n=maria -c="${DB_GO_COMMAND} --defaults-extra-file=/etc/mysql/conf.d/app.cnf ${MYSQL_DB_NAME}"
}
