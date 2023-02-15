#!/usr/bin/env bash

appsStopTest() {
  _wexTestAssertEqual "$(wex apps/list)" ""
}

