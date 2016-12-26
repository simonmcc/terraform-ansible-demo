#!/bin/bash
#
# setup.sh - setup & activate a python virtualenv
# for cloudsystem-automation-scripts
#

if [[ -d .venv ]]; then
  source .venv/bin/activate
else
  virtualenv .venv --system-site-packages
  source .venv/bin/activate
fi

pip install --quiet ansible ansible-lint

ansible-galaxy --ignore-errors --roles-path=./roles install -r requirements.yml
