#!/bin/bash

# Function: Check if package is installed
_isInstalledPacman() {
  package="$1";
  check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package}")"

  if [ -n "${check}" ]; then
    echo 0;

    return;
  fi;

  echo 1;

  return;
}

_isInstalledYay() {
  package="$1";
  check="$(yay -Qs --color always "${package}" | grep "local" | grep "${package}")"

  if [ -n "${check}" ]; then
    echo 0;

    return;
  fi;

  echo 1;

  return;
}

# Function: Install package if not installed
_installPackagesPacman() {
  toInstall=();

  for pkg; do
    if [[ $(_isInstalledPacman "${pkg}") == 0 ]]; then
      echo "${pkg} is already installed.";

      continue;
    fi;

    toInstall+=("${pkg}");
  done;

  if [[ "${toInstall[@]}" == "" ]]; then
    return;
  fi;

  printf "Packages not installed:\n%s\n" "${toInstall[@]}";

  sudo pacman --noconfirm -S "${toInstall[@]}";
}

_installPackagesYay() {
  toInstall=();

  for pkg; do
    if [[ $(_isInstalledPacman "${pkg}") == 0 ]]; then
      echo "${pkg} is already installed.";

      continue;
    fi;

    toInstall+=("${pkg}");
  done;

  if [[ "${toInstall[@]}" == "" ]]; then
    return;
  fi;

  printf "Packages not installed:\n%s\n" "${toInstall[@]}";

  yay --noconfirm -S "${toInstall[@]}";
}
