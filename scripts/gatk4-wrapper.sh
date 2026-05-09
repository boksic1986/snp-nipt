#!/usr/bin/env bash
set -euo pipefail

exec java -jar /home/user/software/gatk-4.6.2.0/gatk-package-4.6.2.0-local.jar "$@"
