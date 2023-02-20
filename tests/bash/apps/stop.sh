#!/usr/bin/env bash

appsStopTest() {
  _wexTestAssertEqual "$(wex-exec apps/list)" ""
}

