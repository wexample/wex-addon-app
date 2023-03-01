#!/usr/bin/env bash

commandInit() {
  _NEEDS_APP_LOCATION=false
}

commandExec() {
  if [ "${_NEEDS_APP_LOCATION}" = "true" ]; then
    # cd to app dir.
    _wexAppGoTo "${APP_DIR:-.}"
    # update var.
    APP_DIR="$(realpath .)/"
  fi
}
