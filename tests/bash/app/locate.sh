#!/usr/bin/env bash

appLocateTest() {
  # Try to locate an app outside wex temp dir.
  _wexTestAssertEqual "$(wex app::app/locate -d="${WEX_DIR_TMP}")" "$(realpath "${WEX_DIR_ROOT}")/"
}
