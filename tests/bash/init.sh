#!/usr/bin/env bash

_appInitTest_createSite() {
  local APP_TEST_FOLDER=${1}
  local SERVICES=${2}

  # go to temp folder
  cd "${WEX_TEST_DIR_TMP}"

  # Folder exists.
  if [[ -d ${APP_TEST_FOLDER} ]];then
    # Do not create.
    return
  fi

  mkdir ${APP_TEST_FOLDER}
  cd "${APP_TEST_FOLDER}"

  _wexLog "Create test site in ${APP_TEST_FOLDER} with services : ${SERVICES[@]}"

  wex app::app/init -s="${SERVICES}"

  wex app::service/exec -c="test"

  _wexLog "Test site created in "${APP_TEST_FOLDER}

  _wexTestAssertEqual "$([[ -d .wex ]] && echo true || echo false)" true
}
