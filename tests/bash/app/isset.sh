#!/usr/bin/env bash

appIssetTest() {
  # Try to locate an dir outside a wex app.
  # Wex core is an app
  _wexTestAssertEqual "$(wex app::app/isset -d="${WEX_DIR_TMP}")" "true"
}
