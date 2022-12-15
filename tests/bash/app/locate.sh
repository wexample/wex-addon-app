#!/usr/bin/env bash

appLocateTest() {
  # Try to locate an dir outside a wex app.
  _wexTestAssertEqual "$(wex app::app/locate -d="${WEX_DIR_TMP}")" ""
}
