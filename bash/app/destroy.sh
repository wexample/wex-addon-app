#!/usr/bin/env bash

appDestroy() {
  wex app::hook/exec -c=appDestroy
  # Removing ket method does not support custom separator for now.
  wex app::config/setValue -b -k=APP_INITIALIZED -v=false
}
