#!/usr/bin/env bash

appDomainsArgs() {
  _DESCRIPTION="Return domains list"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'dir_site d "Root site directory" false'
    'separator s "Separator" false'
  )
}

appDomains() {
  if [ -z "${DIR_SITE+x}" ]; then
    local DIR_SITE=./
  fi

  local DOCKER_COMPOSE_VARS=($(wex-exec app::config/yml -d="${DIR_SITE}"))
  local ALL_DOMAINS=''

  if [ -z "${SEPARATOR+x}" ]; then
    local SEPARATOR=" "
  fi

  for DOCKER_COMPOSE_VAR in "${DOCKER_COMPOSE_VARS[@]}"; do
    local DOMAINS
    DOMAINS=$(sed -n "s/^services_\(.\{0,\}\)_environment_VIRTUAL_HOST\=\"\{0,\}\([^\"]\{0,\}\)\"\{0,\}\$/\2/p" <<<${DOCKER_COMPOSE_VAR})

    if [ ! -z "${DOMAINS+x}" ]; then
      # Split multiple domains.
      DOMAINS=($(echo "${DOMAINS}" | tr "," "\n"))
      for DOMAIN in "${DOMAINS[@]}"; do
        # Add separator.
        if [ "${ALL_DOMAINS}" != "" ]; then
          ALL_DOMAINS+=${SEPARATOR}
        fi
        ALL_DOMAINS+=${DOMAIN}
      done
    fi
  done

  echo "${ALL_DOMAINS}"
}
