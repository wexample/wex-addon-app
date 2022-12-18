#!/usr/bin/env bash

configAddTitleArgs() {
  _ARGUMENTS=(
    'title t "Title text" true'
  )
}

configAddTitle() {
  printf "\n# ${TITLE}" >> "${WEX_FILEPATH_REL_CONFIG_BUILD}"
}
