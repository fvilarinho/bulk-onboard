#!/bin/bash

# Shows the labels.
function showLabel() {
  echo "** Deploying CPCodes, Properties and Security Configurations/Policies ** "

  echo
}

# Shows the banner.
function showBanner() {
  if [ -f "banner.txt" ]; then
    cat banner.txt
  fi

  showLabel
}

# Gets a credential value.
function getCredential() {
  if [ -f "$3" ]; then
    value=$(awk -F'=' '/'$1'/,/^\s*$/{ if($1~/'$2'/) { print substr($0, length($1) + 2) } }' "$3" | tr -d '"' | tr -d ' ')
  else
    value=
  fi

  echo "$value"
}

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Required files/paths.
  WORK_DIR="$PWD/iac"
  CREDENTIALS_FILENAME="$WORK_DIR"/.credentials

  # Environment variables.
  EDGEGRID_SECTION_NAME=default

  if [ -f "$CREDENTIALS_FILENAME" ]; then
    export TF_VAR_edgeGridHost=$(getCredential "$EDGEGRID_SECTION_NAME" "host" "$CREDENTIALS_FILENAME")
    export TF_VAR_edgeGridAccessToken=$(getCredential "$EDGEGRID_SECTION_NAME" "access_token" "$CREDENTIALS_FILENAME")
    export TF_VAR_edgeGridClientToken=$(getCredential "$EDGEGRID_SECTION_NAME" "client_token" "$CREDENTIALS_FILENAME")
    export TF_VAR_edgeGridClientSecret=$(getCredential "$EDGEGRID_SECTION_NAME" "client_secret" "$CREDENTIALS_FILENAME")
  else
    CREDENTIALS_FILENAME=~/.edgerc

    export TF_VAR_edgeGridHost=$(getCredential "$EDGEGRID_SECTION_NAME" "host" "$CREDENTIALS_FILENAME")
    export TF_VAR_edgeGridAccessToken=$(getCredential "$EDGEGRID_SECTION_NAME" "access_token" "$CREDENTIALS_FILENAME")
    export TF_VAR_edgeGridClientToken=$(getCredential "$EDGEGRID_SECTION_NAME" "client_token" "$CREDENTIALS_FILENAME")
    export TF_VAR_edgeGridClientSecret=$(getCredential "$EDGEGRID_SECTION_NAME" "client_secret" "$CREDENTIALS_FILENAME")
  fi

  # Required binaries.
  export TERRAFORM_CMD=$(which terraform)
}

prepareToExecute