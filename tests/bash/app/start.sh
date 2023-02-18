#!/usr/bin/env bash

appStartTest() {
  # Stop sites if exists
  wex apps/stop

  # Clear dir.
  _wexTestClearTempDir

  # Create a new test app for reference,
  # it will be used to compare with other test apps after making changes.
  _appTest_createApp "test-app-ref"

  # Create a new test app if not exists.
  _appTest_createApp "test-app"

  # Go to fist site
  cd "${WEX_TEST_DIR_TMP}test-app"

  # Start website
  wex app/start
}
