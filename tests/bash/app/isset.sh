#!/usr/bin/env bash

appIssetTest() {
  # Try to locate an dir outside a wex app.
  _wexTestAssertEqual "$(wex app::app/isset -d="${WEX_DIR_TMP}")" "false"
}
