#!/usr/bin/env bash

appInitArgs() {
  _ARGUMENTS=(
     'services s "Services to install" true'
     'name n "Site name" false'
     'git g "Init git repository" false true'
     'environment e "Environment (local default)" false local'
     'domains d "Domains names separated by a comma" false'
  )
}

appInit() {
  local RENDER_BAR='wex prompt/progress '
  # Status
  wex prompt/progress -p=0 -s="Init variables"

  local DIR_APP=./

  # Default site name.
  if [ "${NAME}" = "" ]; then
    # Name is current dir name.
    NAME="$(basename "$(realpath "${DIR_APP}")")"
  fi;

  NAME=$(wex string/toSnake -t="${NAME}")

  _wexLog "Using name ${NAME}"

  local APP_DIR_DOCKER=${WEX_DIR_APP_DATA}"docker/"

  # Split services
  local SERVICES_JOINED=$(wex app::service/tree -s="${SERVICES}")
  local SERVICES=$(echo "${SERVICES_JOINED}" | tr "," "\n")

  # Check services exists
  for SERVICE in ${SERVICES[@]}
  do
    if [ ! -d "$(wex app::service/dir -s="${SERVICE}")" ];then
      _wexError "Service missing ${SERVICE}"
      exit
    fi
  done

  # Status
  wex prompt/progress -p=10 -s="Copying base samples files"

  # Copy base site files.
  local SAMPLE_APP_DIR=${WEX_DIR_ADDONS}app/samples/app/
  mkdir -p ${DIR_APP}${WEX_DIR_APP_DATA}
  cp -n -R "${SAMPLE_APP_DIR}.wex/." "${DIR_APP}${WEX_DIR_APP_DATA}"

  # Creating default env file
  if [ ! -f "${WEX_DIR_APP_DATA}.env" ]; then
    echo -e "APP_ENV=${ENVIRONMENT}" > "${WEX_DIR_APP_DATA}.env"
  fi

  local WEX_VERSION
  WEX_VERSION=$(wex core/version)

  if [ "${DOMAINS}" != "" ];then
    local DOMAINS_SPLIT=$(wex string/split -t="${DOMAINS}" -s=",")
    local DOMAINS_MAIN=${DOMAINS_SPLIT[0]}
  else
    local DOMAINS_MAIN=$(wex string/toKebab -t="${NAME}").wex
    local DOMAINS=${DOMAINS_MAIN}
  fi

  {
    echo "# Global"
    echo "AUTHOR=${WEX_RUNNER_USERNAME}"
    echo "CREATED=\"$(date -u)\""
    echo "NAME=${NAME}"
    echo "SERVICES=${SERVICES_JOINED}"
    echo "WEX_VERSION=${WEX_VERSION}"

    printf "\n# Local\n"
    echo "LOCAL_DOMAINS=${DOMAINS}"
    echo "LOCAL_DOMAIN_MAIN=${DOMAINS_MAIN}"
    echo "LOCAL_EMAIL=contact@${DOMAINS_MAIN}"

    printf "\n# Dev\n"
    echo "DEV_DOMAINS=${DOMAINS}"
    echo "DEV_DOMAIN_MAIN=${DOMAINS_MAIN}"
    echo "DEV_EMAIL=contact@${DOMAINS_MAIN}"

    printf "\n# Prod\n"
    echo "PROD_DOMAINS=${DOMAINS}"
    echo "PROD_DOMAIN_MAIN=${DOMAINS_MAIN}"
    echo "PROD_EMAIL=contact@${DOMAINS_MAIN}"
  } >> "${WEX_FILEPATH_REL_CONFIG}"

  for SERVICE in ${SERVICES[@]}
  do
     # Status
    _wexLog "Installing service : ${SERVICE}"
    wex service/install -s="${SERVICE}" -g="${GIT}"
  done

  # GIT Common settings
  _wexLog "Initializing Git settings"
  wex prompt/progress -p=30 -s="Init GIT repo"
  if [ -f "${DIR_APP_DATA}.gitignore.source" ];then
    mv "${DIR_APP_DATA}.gitignore.source" "${DIR_APP_DATA}.gitignore"
  fi

  # Init GIT repo
  if [ "${GIT}" = true ];then
    # Status
    wex prompt/progress -p=50 -s="Install GIT"
    # Create a GIT repo if not exists.
    git init
  fi

  # Status
  wex prompt/progress -p=80 -s="Init services"

  # Init
  wex hook/exec -c=appInit

  # Status
  wex prompt/progress -p=100 -s="Done !"

  if [ "${NEW_NAME}" != "${WEX_PROXY_NAME}" ];then
    _wexMessage "Your app is initialized as ${NEW_NAME}" "You may start install process using :" "wex app/start"
  fi
}
