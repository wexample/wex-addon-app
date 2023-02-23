#!/usr/bin/env bash

promptChooseEnvArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'question q "Question to ask to user" true "Choose env name"'
  )
}

promptChooseEnv() {
  # Build envs list.
  local ALLOWED_ENV="${WEX_APPS_ENVIRONMENTS[*]}";
  ALLOWED_ENV=$(wex-exec array/join -a="${ALLOWED_ENV}" -s=",")

  # Ask user.
  wex-exec prompt::prompt/choice -c="${ALLOWED_ENV}" -q="${QUESTION}"
}