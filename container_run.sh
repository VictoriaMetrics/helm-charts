#!/usr/bin/env bash

#
# A "podman/docker run --rm" wrapper script that runs rootles podman container
# if podman command is present in PATH, otherwise it runs normal docker container.
#

# determine whether podman is present in PATH
command -v podman &> /dev/null
podman_present=$?

# declare cmdargs array that will hold resulting command with arguments
declare -a cmdargs=()

if [ $podman_present -eq 0 ]; then
  cmdargs+=("podman" "run" "--rm")
else
  # append --user option for docker only
  cmdargs+=("docker" "run" "--rm" "--user" "$(id -u):$(id -g)")
fi

while [ "$#" -gt 0 ]; do
  if [ "$1" = "--volume" ] || [ "$1" = "-v" ]; then
    if [ $podman_present -eq 0 ]; then
      # append :z to --volume option argument for rootless podman in case
      # we're on a SELinux enabled system (if SELinux is not enabled, this is no-op)
      cmdargs+=("$1")
      shift
      cmdargs+=("${1}:z")
      shift
    else
      # pass unchanged --volume option argument for docker
      cmdargs+=("$1")
      shift
      cmdargs+=("$1")
      shift
    fi
  else
    # other arguments are passed unchanged
    cmdargs+=("$1")
    shift
  fi
done

#echo "${cmdargs[@]}"

exec "${cmdargs[@]}"
