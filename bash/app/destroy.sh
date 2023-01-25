#!/usr/bin/env bash

appDestroy() {
  _wexAppGoTo

  # Ensure app is stopped
  wex app/stop

  # Execute hooks.
  wex app::hook/exec -c=appDestroy

  # Removing key method does not support custom separator for now.
  wex app::config/setValue -b -k=APP_INITIALIZED -v=false
}
