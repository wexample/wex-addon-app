#!/usr/bin/env bash

proxyAppFirstStartInit() {
  _wexLog "Setting logs redirection to Docker logs"

  wex-exec app/exec -vv -c="ln -fs /proc/1/fd/1 /var/log/nginx/access.log"
  wex-exec app/exec -vv -c="ln -fs /proc/1/fd/2 /var/log/nginx/error.log"
  wex-exec app/exec -vv -c="nginx -s reload"
}
