#!/usr/bin/env bash

serviceInstallTest() {
  # Stop sites if exists
  wex docker/stopAll

  _appTest_checkAppsCount 0

  # Clear dir.
  _wexTestClearTempDir

  # Create a new test app for reference,
  # it will be used to compare with other test apps after making changes.
  _appTest_createApp "test-app-ref"

  # Create a new test app if not exists.
  _appTest_createApp "test-app"

  # Go to fist site
  cd "${WEX_TEST_DIR_TMP}test-app"

  local SERVICES
  SERVICES=$(wex app::services/all)

  for SERVICE in ${SERVICES[@]}
  do
    _wexLog "Installing service... ${SERVICE}"
    wex app::service/install -s="${SERVICE}"
  done
}

