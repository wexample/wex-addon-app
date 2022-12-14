#!/usr/bin/env bash

serviceInstallArgs() {
  _ARGUMENTS=(
    'service s "Service to install" true'
    'git g "Init git repository" false'
  )
}

serviceInstall() {
  local DIR_SITE=./
  local SERVICE_SAMPLE_DIR
  local FILES

  SERVICE_SAMPLE_DIR="$(wex service/dir -s="${SERVICE}")samples/"

  # Copy all files from samples
  if [ -d "${SERVICE_SAMPLE_DIR}" ];then
    FILES=$(ls -a "${SERVICE_SAMPLE_DIR}")
    for FILE in ${FILES[@]};do
      if [ "${FILE}" != "." ] && [ "${FILE}" != ".." ];then
        # Docker files
        if [ "${FILE}" == "docker" ] && [ -d "${SERVICE_SAMPLE_DIR}${FILE}" ];then
          # Merge default yml
          serviceInstallMergeYml "yml"
          # Fore each env type.
          local ENV
          for ENV in ${WEX_APPS_ENVIRONMENTS[@]};do
            # Search for *.envName.yml
            serviceInstallMergeYml "${ENV}.yml"
          done
        # Git
        elif [ "${FILE}" = ".gitignore.source" ];then
          if [ "${GIT}" = "true" ];then
            echo -e "" >> ${DIR_SITE}".gitignore"
            cat "${SERVICE_SAMPLE_DIR}${FILE}" >> ${DIR_SITE}".gitignore"
          fi
        # .env files (merged files)
        elif [ "${FILE}" = ".env" ];then
            touch "${DIR_SITE}${FILE}"
            echo -e "" >> "${DIR_SITE}${FILE}"
            cat "${SERVICE_SAMPLE_DIR}${FILE}" >> "${DIR_SITE}${FILE}"
        else
          cp -n -R "${SERVICE_SAMPLE_DIR}${FILE}" ${DIR_SITE}
        fi
      fi
    done
  fi
}

serviceInstallMergeYml() {
  local EXT=${1}
  local YML_SOURCE_BASE="${SERVICE_SAMPLE_DIR}docker/docker-compose"
  local YML_SOURCE_FILE="${YML_SOURCE_BASE}.${EXT}"
  local YML_DEST_FILE="${DIR_SITE}${WEX_DIR_APP_DATA}docker/docker-compose.${EXT}"
  local YML_CONTENT=''

  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG}"

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
      # Match with files to merge as services.
      if [ "${FILENAME:0:15}" == 'docker-compose-' ];then
        SUFFIX="_"${FILENAME:15:-4}
      fi

      # Append
      YML_CONTENT+="    "${NAME}_${SERVICE}${SUFFIX}":\n"
      YML_CONTENT+=$(cat "${FILE_TO_MERGE}")"\n"
    done
  fi

  if [ "${YML_CONTENT}" != "" ];then
      # Create file if not exists.
      if [ ! -f "${YML_DEST_FILE}" ];then
        echo -e "version: '3'\n\nservices:" > "${YML_DEST_FILE}"
      fi
      # Append to yml file
      echo -e "${YML_CONTENT}" > "${YML_DEST_FILE}".tmp
      sed -i"${WEX_SED_I_ORIG_EXT}" -e "/services:/r ${YML_DEST_FILE}.tmp" "${YML_DEST_FILE}"
      rm "${YML_DEST_FILE}""${WEX_SED_I_ORIG_EXT}"
      rm "${YML_DEST_FILE}".tmp
  fi
}