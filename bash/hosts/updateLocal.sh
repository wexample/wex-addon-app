#!/usr/bin/env bash

hostsUpdateLocal() {
  # Remove old blocks
  sudo sed -i"${WEX_SED_I_ORIG_EXT}" -e '/\#\[ wex \]\#/,/\#\[ endwex \]\#/d' "${WEX_SYSTEM_HOST_FILE}"
  sudo rm "${WEX_SYSTEM_HOST_FILE}${WEX_SED_I_ORIG_EXT}"
  # Add new line if needed.

  # Create new block.
  echo -e "#[ wex ]#" | sudo tee -a "${WEX_SYSTEM_HOST_FILE}" > /dev/null
  cat "${WEX_DIR_PROXY_TMP}hosts" | sudo tee -a "${WEX_SYSTEM_HOST_FILE}" > /dev/null
  echo -e "\n#[ endwex ]#" | sudo tee -a "${WEX_SYSTEM_HOST_FILE}" > /dev/null
}
