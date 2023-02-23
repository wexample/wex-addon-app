#!/usr/bin/env bash

serviceInstallArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'git g "Merge git sources" false true'
    'install_config ic "Add to config" true true'
    'install_docker id "Merge docker files" true true'
    'install_git ig "Merge git files" true true'
    'install_env ie "Merge env files" true true'
    'install_remaining ir "Copy files wich is not in the other files" true true'
    'service s "Service to install" true'
  )
}

serviceInstall() {
  _wexAppGoTo .

  local SERVICES
  SERVICES=($(wex-exec services/list))

  _wexLog "Installing service : ${SERVICE}"

  if [[ " ${SERVICES[@]} " =~ " ${SERVICE} " ]]; then
    _wexLog "Service already installed : ${SERVICE}"
    return
  fi

  # Update config.
  if [ "${INSTALL_CONFIG}" = "true" ];then
    SERVICES+=("${SERVICE}")
    SERVICES=($(echo "${SERVICES[*]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    SERVICES=$(wex-exec array/join -a="${SERVICES[*]}" -s=",")

    wex-exec app::config/setValue -b -k=SERVICES -v="$(wex-exec array/join -a="${SERVICES}" -s=",")"
  fi

  local SERVICE_DIR
  local SERVICE_SAMPLE_DIR
  local SERVICE_SAMPLE_DIR_WEX
  local FILES

  SERVICE_DIR="$(wex-exec service/dir -s="${SERVICE}")"
  SERVICE_SAMPLE_DIR="${SERVICE_DIR}samples/"
  SERVICE_SAMPLE_DIR_WEX="${SERVICE_SAMPLE_DIR}.wex/"

  # Copy all files from samples
  if [ -d "${SERVICE_SAMPLE_DIR_WEX}" ];then
    FILES=$(ls -a "${SERVICE_SAMPLE_DIR_WEX}")

    # Merge docker files.
    for FILE in ${FILES[@]}; do
      if [ "${FILE}" != "." ] && [ "${FILE}" != ".." ]; then
        if [ "${FILE}" == "docker" ] && [ -d "${SERVICE_SAMPLE_DIR_WEX}${FILE}" ]; then
          if [ "${INSTALL_DOCKER}" = "true" ];then
            serviceInstallMergeYml "yml"
            local ENV
            for ENV in ${WEX_APPS_ENVIRONMENTS[@]}; do
              serviceInstallMergeYml "${ENV}.yml"
            done
          fi
          # Remove from queued files
          FILES=("${FILES[@]/$FILE}")
        fi
      fi
    done

    # Merge git files.
    for FILE in ${FILES[@]}; do
      if [ "${FILE}" = ".gitignore.source" ];then
        if [ "${GIT}" = "true" ];then
          if [ "${INSTALL_GIT}" = "true" ];then
            _wexLog "Merging gitignore : ${FILE}"

            echo -e "" >> "${WEX_DIR_APP_DATA}.gitignore"
            cat "${SERVICE_SAMPLE_DIR_WEX}${FILE}" >> "${WEX_DIR_APP_DATA}.gitignore"
          fi

          # Remove from queued files
          FILES=("${FILES[@]/$FILE}")
        fi
      fi
    done

    # Merge env files.
    for FILE in ${FILES[@]}; do
      if [ "${FILE}" = ".env" ];then
        if [ "${INSTALL_ENV}" = "true" ];then
          _wexLog "Merging env : ${FILE}"

          touch "${WEX_DIR_APP_DATA}${FILE}"
          echo -e "" >> "${WEX_DIR_APP_DATA}${FILE}"
          cat "${SERVICE_SAMPLE_DIR_WEX}${FILE}" >> "${WEX_DIR_APP_DATA}${FILE}"
        fi
        # Remove from queued files
        FILES=("${FILES[@]/$FILE}")
      fi
    done

    # Copy remaining files.
    for FILE in ${FILES[@]}; do
      if [ "${INSTALL_REMAINING}" = "true" ];then
        _wexLog "Copying : ${FILE}"
        cp -n -R "${SERVICE_SAMPLE_DIR_WEX}${FILE}" "${WEX_DIR_APP_DATA}"
      fi
    done
  fi

  wex-exec app::service/exec -s="${SERVICE}" -c=serviceInstall -a="${GIT}"

  local DEPENDENCIES=()
  local SERVICE_CONFIG="${SERVICE_DIR}${WEX_FILE_SERVICE_CONFIG}"

  if [ -f "${SERVICE_CONFIG}" ];then
    . "${SERVICE_CONFIG}"
    DEPENDENCIES=($(wex-exec string/split -t="${DEPENDENCIES}" -s=","))

    for DEPENDENCY in ${DEPENDENCIES[@]};do
      wex app::service/install -s="${DEPENDENCY}"
    done
  fi
}

serviceInstallMergeYml() {
  local EXT=${1}
  local YML_SOURCE_BASE="${SERVICE_SAMPLE_DIR}.wex/docker/docker-compose"
  local YML_SOURCE_FILE="${YML_SOURCE_BASE}.${EXT}"
  local YML_DEST_FILE="${WEX_DIR_APP_DATA}docker/docker-compose.${EXT}"
  local YML_CONTENT=''

  . "${WEX_FILEPATH_REL_CONFIG}"

  if [ -f "${YML_SOURCE_FILE}" ];then
    local YML_FILES_TO_MERGE=(${YML_SOURCE_FILE})
    YML_FILES_TO_MERGE+=($(ls ${YML_SOURCE_BASE}-* 2>/dev/null))

    local FILE_TO_MERGE
    local FILENAME
    local SUFFIX
    for FILE_TO_MERGE in ${YML_FILES_TO_MERGE[@]};do
      # Report suffixes to service name.
      SUFFIX=''
      FILENAME=$(basename "${FILE_TO_MERGE}")

      _wexLog "Merging docker file : ${FILENAME}"

      # Match with files to merge as services.
      if [ "${FILENAME:0:15}" == 'docker-compose-' ];then
        SUFFIX="_$(echo "${FILENAME}" | sed 's/.*-\([^.]*\)\..*/\1/')"
      fi

      # Append
      YML_CONTENT+="    "${NAME}_${SERVICE}${SUFFIX}":\n"
      YML_CONTENT+=$(cat "${FILE_TO_MERGE}")"\n"
    done
  fi

  if [ "${YML_CONTENT}" != "" ];then
      # Create file if not exists.
      if [ ! -f "${YML_DEST_FILE}" ];then
        _wexLog "Creating new docker file : ${YML_DEST_FILE}"

        echo -e "version: '3'\n\nservices:" > "${YML_DEST_FILE}"
      fi

      _wexLog "Filling up : ${YML_DEST_FILE}"
      # Append to yml file
      echo -e "${YML_CONTENT}" > "${YML_DEST_FILE}".tmp
      sed -i"${WEX_SED_I_ORIG_EXT}" -e "/services:/r ${YML_DEST_FILE}.tmp" "${YML_DEST_FILE}"
      rm "${YML_DEST_FILE}""${WEX_SED_I_ORIG_EXT}"
      rm "${YML_DEST_FILE}".tmp
  fi
}