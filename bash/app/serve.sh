#!/usr/bin/env bash

appServe() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Update host file if user has write access.
  if [ "${APP_ENV}" = "local" ] && [ "$(sudo wex file/writable -f=/etc/hosts)" = "true" ];then
    wex app::hosts/updateLocal
  fi

  if [ "$(wex app::app/started)" = "true" ];then
    # Refresh services (ex apache restart)
    wex hook/exec -c=appServe
  fi
}