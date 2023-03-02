#!/usr/bin/env bash

serviceInstallTest() {

  local SERVICES
  SERVICES=$(wex-exec app::services/all)

  for SERVICE in ${SERVICES[@]}; do
    if [[ "${SERVICE}" != "default" && "${SERVICE}" != "proxy" ]]; then
      _wexLog "_____ Testing service : ${SERVICE}"

      # Stop sites if exists
      wex-exec docker/stopAll

      _serviceInstallTestAppRunning false

      # Clear dir.
      _wexTestClearTempDir

      # Create a new test app if not exists.
      _appTest_createApp "test-app"

      # Go to fist site
      cd "${WEX_TEST_DIR_TMP}test-app"

      wex-exec app::service/install -s="${SERVICE}"

      wex-exec app::app/start

      local TAGS=""
      local SERVICE_CONFIG="$(wex-exec app::service/dir -s="${SERVICE}")${WEX_FILE_SERVICE_CONFIG}"

      if [ -f "${SERVICE_CONFIG}" ]; then
        . "${SERVICE_CONFIG}"

        TAGS=$(wex-exec default::string/split -t="${TAGS}" -s=",")

        for TAG in ${TAGS[@]}; do
          _wexLog "Test service tag : ${TAG}"

          local SERVICE_HOOK_TESTS=()

          if [ "${TAG}" = "db" ]; then
            SERVICE_HOOK_TESTS+=(
              dbExec
              #              dbDump
              #              dbRestore
            )
          fi

          for SERVICE_HOOK_TEST in ${SERVICE_HOOK_TESTS[@]}; do
            _wexLog "Test service hook : ${SERVICE_HOOK_TEST}"
            wex-exec app::service/exec -s="${SERVICE}" -sf -c="${SERVICE_HOOK_TEST}" --test
          done
        done
      fi

      _serviceInstallTestAppRunning true

      wex-exec app::app/stop

      _wexLog "Remove service... ${SERVICE}"
      wex-exec app::service/remove -s=${SERVICE}
    fi
  done
}

_serviceInstallTestAppRunning() {
  RUNNING=true
  # At least one container runs.
  if [ "$(docker ps -a | grep test_app_)" = "" ]; then
    RUNNING=false
  fi

  _wexTestAssertEqual "${RUNNING}" "${1}"
}
