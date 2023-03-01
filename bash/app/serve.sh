#!/usr/bin/env bash

appServeArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'app_dir ad "Application directory" false'
  )
}

appServe() {
  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Update host file if user has write access.
  if [ "${APP_ENV}" = "local" ] && [ "$(sudo -E wex file/writable -f=/etc/hosts)" = "true" ]; then
    wex-exec app::hosts/updateLocal
  fi

  if [ "$(wex-exec app::app/started)" = "true" ]; then
    # Refresh services (ex apache restart)
    wex-exec hook/exec -c=appServe
  fi
}
