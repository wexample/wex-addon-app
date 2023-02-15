#!/usr/bin/env bash

appsListTest() {
  local FILE_EXISTS=false

  if [ -f "${WEX_PROXY_APPS_REGISTRY}" ];then
    sudo rm "${WEX_PROXY_APPS_REGISTRY}"
  fi

  _wexTestAssertEqual "$(wex apps/list)" ""
}

