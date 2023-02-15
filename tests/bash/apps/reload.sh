#!/usr/bin/env bash

appsReloadTest() {
  local FILE_EXISTS=false

  if [ -f "${WEX_PROXY_APPS_REGISTRY}" ];then
    sudo rm "${WEX_PROXY_APPS_REGISTRY}"
  fi

  wex apps/reload

  if [ -f "${WEX_PROXY_APPS_REGISTRY}" ];then
    FILE_EXISTS=true
  fi

  _wexTestAssertEqual "${FILE_EXISTS}" true
}

