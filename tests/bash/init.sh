#!/usr/bin/env bash

_appTest_createApp() {
  local APP_TEST_FOLDER=${1}
  local SERVICES=${2}

  # go to temp folder
  cd "${WEX_TEST_DIR_TMP}"

  # Folder exists.
  if [ -d "${APP_TEST_FOLDER}" ];then
    # Do not create.
    return
  fi

  mkdir ${APP_TEST_FOLDER}
  cd "${APP_TEST_FOLDER}"

  _wexLog "Create test site in ${APP_TEST_FOLDER} with services : ${SERVICES[@]}"

  wex app::app/init -s="${SERVICES}"

  wex app::service/exec -c="test"

  _wexLog "Test site created in "${APP_TEST_FOLDER}

  _wexTestAssertEqual "$([ -d .wex ] && echo true || echo false)" true
}

_appTest_checkAppsCount() {
  _appTest_checkConfLines ${1} "apps"
}

_appTest_checkConfLines() {
  local FILE_NAME=${2}
  local COUNT=0

  _wexLog "Check running in ${WEX_DIR_PROXY_TMP}${FILE_NAME}"
  local EXPECTED=${1}

  if [ -f ${WEX_PROXY_APPS_REGISTRY} ];then
    COUNT=$(wex file/linesCount -i -f="${WEX_DIR_PROXY_TMP}${FILE_NAME}")
  else
    _wexLog "Server is stopped (no ${FILE_NAME} file)"
  fi

  _wexLog "Running ${FILE_NAME} count : ${COUNT}, expected ${EXPECTED}"
  _wexTestAssertEqual "$([[ "${COUNT}" == "${EXPECTED}" ]] && echo true || echo false)" "true"
}
