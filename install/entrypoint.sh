#!/bin/bash

set -e

_link() {
  # this funciton does nothing is $2 is already linked to $1
  # if $1 doesn't exist, it's created then content in $2 is copied to $1
  # otherwise, remove $2 and recreate link
  if [[ -L ${2} && $(readlink ${2}) == ${1} ]]; then
    return 0
  fi
  if [[ ! -e ${1} ]]; then
    if [[ -d ${2} ]]; then
      mkdir -p "${1}"
      pushd ${2} &>/dev/null
      find . -type f -exec cp --parents '{}' "${1}/" \;
      popd &>/dev/null
    elif [[ -f ${2} ]]; then
      if [[ ! -d $(dirname ${1}) ]]; then
        mkdir -p $(dirname ${1})
      fi
      cp -f "${2}" "${1}"
    else
      mkdir -p "${1}"
    fi
  fi
  if [[ -d ${2} ]]; then
    rm -rf "${2}"
  elif [[ -f ${2} || -L ${2} ]]; then
    rm -f "${2}"
  fi
  if [[ ! -d $(dirname ${2}) ]]; then
    mkdir -p $(dirname ${2})
  fi
  ln -sf ${1} ${2}
}

_link /conf/id /var/lib/crashplan
_link /conf/conf /usr/local/crashplan/conf
_link /conf/run.conf /usr/local/crashplan/bin/run.conf

_link /data/backupArchives /usr/local/var/crashplan
_link /data/cache /usr/local/crashplan/cache
_link /data/log /usr/local/crashplan/log

exec "$@"
