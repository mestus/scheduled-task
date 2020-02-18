#!/bin/bash
DATE=$(date +"%Y%m%d")
TIME=$(date +"%H%M%S")
VERSION="1.0.$DATE.$TIME"

set -x

/opt/octo/Octo pack --basePath="$PWD/published" --id="Mestus.ScheduledTask" --version="$VERSION" || exit 1
/opt/octo/Octo push --package="Mestus.ScheduledTask.$VERSION.nupkg" --server=https://mestus.octopus.app || exit 1
