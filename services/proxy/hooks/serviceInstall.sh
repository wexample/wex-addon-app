#!/usr/bin/env bash

proxyServiceInstall() {
  wex-exec app::config/setValue -b -k=MAIN_CONTAINER_NAME -v="proxy"
}