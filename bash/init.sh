#!/usr/bin/env bash

WEX_DIR_PROXY=$([[ "$(uname -s)" == Darwin ]] && echo /Users/.wex/server/ || echo /opt/wex_server/)    # /opt can't be mounted on macos, using Users instead.

export WEX_APPS_ENVIRONMENTS=(local dev prod)
export WEX_PROXY_APPS_REGISTRY=${WEX_DIR_PROXY_TMP}apps
export WEX_DIR_PROXY
export WEX_DIR_PROXY_TMP=${WEX_DIR_PROXY}tmp/
