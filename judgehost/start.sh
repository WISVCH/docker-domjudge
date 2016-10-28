#!/bin/bash
set -e

/opt/domjudge/judgehost/bin/create_cgroups
exec sudo -u domjudge "$@"
