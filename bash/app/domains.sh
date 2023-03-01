#!/usr/bin/env bash

appDomainsArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Return domains list"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'app_dir ad "Application directory" false'
    'separator s "Separator" false'
  )
}

appDomains() {
  local DOCKER_COMPOSE_VARS
  mapfile -t DOCKER_COMPOSE_VARS < <(wex-exec app::config/yml -ad="${APP_DIR}")
  local ALL_DOMAINS=''

  if [ -z "${SEPARATOR+x}" ]; then
    local SEPARATOR=" "
  fi

  local IFS_OLD=${IFS}
  IFS=','
  for DOCKER_COMPOSE_VAR in "${DOCKER_COMPOSE_VARS[@]}"; do
    local DOMAINS
    DOMAINS=$(sed -n "s/^services_\(.\{0,\}\)_environment_VIRTUAL_HOST\=\"\{0,\}\([^\"]\{0,\}\)\"\{0,\}\$/\2/p" <<<${DOCKER_COMPOSE_VAR})

    if [ -n "${DOMAINS+x}" ]; then
      # Split multiple domains.
      read -ra DOMAINS <<<"${DOMAINS}"

      for DOMAIN in "${DOMAINS[@]}"; do
        # Add separator.
        if [ "${ALL_DOMAINS}" != "" ]; then
          ALL_DOMAINS+=${SEPARATOR}
        fi
        ALL_DOMAINS+=${DOMAIN}
      done
    fi
  done
  IFS=${IFS_OLD}

  echo "${ALL_DOMAINS}"
}
