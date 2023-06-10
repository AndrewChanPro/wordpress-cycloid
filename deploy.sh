#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

packer build packer.json
cd terraform
terraform apply -auto-approve