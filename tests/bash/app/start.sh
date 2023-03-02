#!/usr/bin/env bash

appStartTest() {
  # Stop sites if exists
  wex-exec docker/stopAll
  echo "" > "${WEX_PROXY_APPS_REGISTRY}"

  _appTest_checkAppsCount 0

  # Clear dir.
  _wexTestClearTempDir

  # Create a new test app if not exists.
  _appTest_createApp "test-app"

  # Go to fist site
  cd "${WEX_TEST_DIR_TMP}test-app"

  _wexLog "Start test app"
  # Start website
  wex-exec app::app/start

  # Proxy server started.
  _wexTestAssertEqual "$([[ $(docker ps -a | grep wex_server) != "" ]] && echo true || echo false)" "true"

  # One line
  _appTest_checkAppsCount 2

  # Start website again
  _wexLog "Start test app again"
  wex-exec app::app/start

  # One line
  _appTest_checkAppsCount 2

  # Create a new test site if not exists.
  _appTest_createApp "test-app-2"
  # Go to second site
  cd "${WEX_TEST_DIR_TMP}test-app-2"
  # Start second site

  _wexLog "Start second app"
  wex-exec app::app/start
  _appTest_checkAppsCount 3

  wex-exec app::app/restart
  _appTest_checkAppsCount 3

  # Return to fist site
  cd "${WEX_TEST_DIR_TMP}test-app"
  _wexLog "Stop first site"

  wex-exec app::app/stop
  _appTest_checkAppsCount 2

  # Stop all sites
  _wexLog "Stop all site (second site should remain)"

  wex-exec app::apps/stop
  _appTest_checkAppsCount 1

  wex-exec app::proxy/stop
  _appTest_checkAppsCount 0
}
