#!/usr/bin/env bash

commandInit() {
  _NEEDS_APP_LOCATION=false
  DIR=""
}

commandExec() {
  if [ "${_NEEDS_APP_LOCATION}" = "true" ]; then
    _wexAppGoTo "${DIR:-.}"
  fi
}
