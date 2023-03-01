#!/usr/bin/env bash

appIssetTest() {
  # Try to locate an dir outside a wex app.
  # Wex core is an app
  _wexTestAssertEqual "$(wex-exec app::app/isset -ad="${WEX_DIR_TMP}")" "true"
}
