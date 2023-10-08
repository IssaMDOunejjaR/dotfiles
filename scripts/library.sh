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
      echo "  ✔ ${pkg}";

      continue;
    fi;

    toInstall+=("${pkg}");
  done;

  if [[ "${toInstall[@]}" == "" ]]; then
    return;
  fi;

  for pkg in "${toInstall[@]}"
  do
    echo -n "  - Installing $pkg...";

    sudo pacman --noconfirm -S "${pkg}" 1> /dev/null;

    if [ $? -neq 0 ]; then
      echo -e "\r  ✘ $pkg: ";
    else
      echo -e "\r  ✔ $pkg";
    fi
  done
}

_installPackagesYay() {
  toInstall=();

  for pkg; do
    if [[ $(_isInstalledPacman "${pkg}") == 0 ]]; then
      echo "  ✔ ${pkg}";

      continue;
    fi;

    toInstall+=("${pkg}");
  done;

  if [[ "${toInstall[@]}" == "" ]]; then
    return;
  fi;

  for pkg in "${toInstall[@]}"
  do
    echo -n "  - Installing $pkg...";

    yay --noconfirm -S "${pkg}" 1> /dev/null;

    echo -e "\r  ✔ $pkg";
  done

}

_installSymLink() {
  symlink="$1";
  linksource="$2";
  linktarget="$3";

    if [ -L "${symlink}" ]; then
      rm ${symlink}

      ln -s ${linksource} ${linktarget} 

      echo "Symlink ${linksource} -> ${linktarget} created."
    else
      if [ -d ${symlink} ]; then
        rm -rf ${symlink}/ 

        ln -s ${linksource} ${linktarget}

        echo "Symlink for directory ${linksource} -> ${linktarget} created."
      else
        if [ -f ${symlink} ]; then
          rm ${symlink} 

          ln -s ${linksource} ${linktarget} 

          echo "Symlink to file ${linksource} -> ${linktarget} created."
        else
          ln -s ${linksource} ${linktarget} 

          echo "New symlink ${linksource} -> ${linktarget} created."
        fi
      fi
    fi
}
