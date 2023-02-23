#!/usr/bin/env bash

envGetVarArgs() {
  # shellcheck disable=SC2034
  _DESCRIPTION="Get env related variable value"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'env e "Environment name" false'
    'variable_name n "Variable suffix (prefixed after _, ie VAR_NAME for PROD_VAR_NAME)" true'
  )
}

envGetVar() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"
  ENV="${ENV:-${APP_ENV}}"
  ENV=${ENV^^}
  eval 'echo ${'${ENV}'_'${VARIABLE_NAME^^}'}'
}