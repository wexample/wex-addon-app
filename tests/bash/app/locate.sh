#!/usr/bin/env bash

appLocateTest() {
  # Try to locate an app outside wex temp dir.
  _wexTestAssertEqual "$(wex-exec app::app/locate -ad="${WEX_DIR_TMP}")" "$(realpath "${WEX_DIR_ROOT}")/"
}
