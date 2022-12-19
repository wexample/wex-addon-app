#!/usr/bin/env bash

appEnv() {
  cd "$(wex app::app/locate -d="${DIR}")"

  if [ -f "${WEX_FILEPATH_REL_APP_ENV}" ];then
    wex bash/readVar -f="${WEX_FILEPATH_REL_APP_ENV}" -k=APP_ENV
  fi
}