#!/usr/bin/env bash

configBindFilesArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Create env variables based on available config files to use id docker compose files"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'section s "Section name, cat be a folder name" true'
    'extension e "Extension for file" false'
  )
}

configBindFiles() {
  local FOLDER="./${WEX_DIR_APP_DATA}/${SECTION}"
  local SECTION_FILES=$(ls "${FOLDER}")
  local NAMES_PROCESSED=()

  # Get site env name.
  local APP_ENV=$(wex-exec app::app/env)

  for FILE in ${SECTION_FILES[@]}; do
    SPLIT=($(wex-exec default::string/split -s="." -t="${FILE}"))
    BASE_NAME=${SPLIT[0]}

    # Base file ex container.ext
    local CONF_VAR_NAME=${SPLIT[@]}
    local IS_ENV=false

    # There is more than two pieces
    if [ "${SPLIT[2]}" != "" ]; then
      local IS_ENV=true
      # Second part si equal to
      if [ "${SPLIT[1]}" == "${APP_ENV}" ]; then
        # Remove env name
        CONF_VAR_NAME=${SPLIT[0]}" "${SPLIT[2]}
        # This is an unexpected.name.ext
      else
        CONF_VAR_NAME=false
      fi
    fi

    # One execution only by base name,
    # Search for file variations inside it.
    # Allow to write same variable two times if env file is found after generic one.
    if [ "${CONF_VAR_NAME}" != false ] && ([[ ! " ${NAMES_PROCESSED[@]} " =~ " ${SPLIT[0]} " ]] || [ ${IS_ENV} == true ]); then
      # Save as found
      NAMES_PROCESSED+=(${SPLIT[0]})

      # Return to array
      CONF_VAR_NAME=(${CONF_VAR_NAME})
      # Append folder name in second position
      CONF_VAR_NAME="${SPLIT[0]} ${SECTION} ${CONF_VAR_NAME[@]:1}"
      CONF_VAR_NAME=$(wex-exec array/join -a="${CONF_VAR_NAME}" -s="_")
      CONF_VAR_NAME="CONF_"${CONF_VAR_NAME^^}
      local FILE=$(realpath ${FOLDER}'/'${FILE})

      # Not already found.
      wex-exec app::config/setValue -k="${CONF_VAR_NAME}" -v="${FILE}"
    fi
  done
}
