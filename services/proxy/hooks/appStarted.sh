#!/usr/bin/env bash

proxyAppStarted() {
  . "${WEX_FILEPATH_REL_CONFIG}"

  # Check if a process is using port 80 (or given port)
  local PROCESSES
  PROCESSES=$(netstat -tulpn | grep ":${WEX_SERVER_PORT_PUBLIC}")
  if [ "$(wex system::port/used -p=${WEX_SERVER_PORT_PUBLIC})" ];then
    _wexError "A process is already running on port ${WEX_SERVER_PORT_PUBLIC}"
    sudo netstat -tunlp | grep ":${WEX_SERVER_PORT_PUBLIC} "
    exit
  fi

  # Copy FTP access to FTP global container.
  local FTP_PASSWD_LOCAL=./ftp/passwd/${APP_NAME}.passwd
  # Access file exists.
  if [ -f ${FTP_PASSWD_LOCAL} ];then
    # File in ftp container.
    local FTP_PASSWD=/etc/pure-ftpd/passwd/${APP_NAME}.passwd
    # Copy.
    docker cp ${FTP_PASSWD_LOCAL} wex_ftp:${FTP_PASSWD}
    # Give access.
    docker exec wex_ftp chmod 600 ${FTP_PASSWD}
    # Reload FTP service.
    docker exec wex_ftp service pure-ftpd force-reload
  fi
}