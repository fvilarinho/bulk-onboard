#!/bin/bash

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  export TERRAFORM_PLAN_FILENAME=/tmp/natura-bulk-onboard.plan

  source functions.sh

  showBanner

  cd iac || exit 1
}

# Starts the provisioning based on the IaC files.
function deploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD plan -out "$TERRAFORM_PLAN_FILENAME" || exit 1

  $TERRAFORM_CMD apply \
                 -auto-approve \
                 "$TERRAFORM_PLAN_FILENAME"
}

# Clean-up.
function cleanUp() {
  rm -f "$TERRAFORM_PLAN_FILENAME"
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  deploy
  cleanUp
}

main