#!/usr/bin/env bash

appDestroyArgs() {
  _NEEDS_APP_LOCATION=true
  _ARGUMENTS=(
    "${WEX_APP_ARG_APP_DIR}"
  )
}

appDestroy() {
  # Ensure app is stopped
  wex-exec app/stop

  # Execute hooks.
  wex-exec app::hook/exec -c=appDestroy

  # Removing key method does not support custom separator for now.
  wex-exec app::config/setValue -b -k=APP_INITIALIZED -v=false
}
