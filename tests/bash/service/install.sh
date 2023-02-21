#!/usr/bin/env bash

serviceInstallTest() {
  # Stop sites if exists
  wex-exec docker/stopAll

  local SERVICES
  SERVICES=$(wex-exec app::services/all)

  for SERVICE in ${SERVICES[@]}; do
    if [[ "${SERVICE}" != "default" && "${SERVICE}" != "proxy" ]]; then
      # Clear dir.
      _wexTestClearTempDir

      # Create a new test app for reference,
      # it will be used to compare with other test apps after making changes.
      _appTest_createApp "test-app-ref"

      # Create a new test app if not exists.
      _appTest_createApp "test-app"

      # Go to fist site
      cd "${WEX_TEST_DIR_TMP}test-app"

      wex-exec app::service/install -s="${SERVICE}"

      _wexLog "Starting app with new service"
      wex-exec app/start

      _wexLog "Test service started : ${SERVICE}"
      _wexTestAssertEqual "$(wex-exec app/started)" true

      local TAGS=""
      local SERVICE_CONFIG="$(wex-exec app::service/dir -s="${SERVICE}")${WEX_FILE_SERVICE_CONFIG}"

      if [ -f "${SERVICE_CONFIG}" ];then
        . "${SERVICE_CONFIG}"

        TAGS=$(wex-exec default::string/split -t="${TAGS}" -s=",")

        for TAG in ${TAGS[@]}; do
          _wexLog "Test service tag : ${TAG}"

          local SERVICE_HOOK_TESTS=()

          if [ "${TAG}" = "db" ];then
            SERVICE_HOOK_TESTS+=(
              dbConnect
            )
          fi

          for SERVICE_HOOK_TEST in ${SERVICE_HOOK_TESTS[@]}; do
            _wexLog "Test service hook : ${SERVICE_HOOK_TEST}"
            wex-exec app::service/exec -s="${SERVICE}" -sf -c="${SERVICE_HOOK_TEST}" --test
          done
        done
      fi

      wex-exec app/stop

      _wexLog "Remove service... ${SERVICE}"
      wex-exec app::service/remove -s=${SERVICE}
    fi
  done
}
