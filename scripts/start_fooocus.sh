#!/usr/bin/env bash

export HF_HOME="/workspace"
VENV_PATH=$(cat /workspace/Fooocus/venv_path)
source ${VENV_PATH}/bin/activate
cd /workspace/Fooocus

ARGS="--listen --port 3001 ${CMDARGS}"

if [[ ${PRESET} ]]
then
    ARGS = "${ARGS} --preset ${PRESET}"    
fi

echo "Starting Fooocus using args: ${ARGS}"
nohup python3 entry_with_update.py ${ARGS} > /workspace/logs/fooocus.log 2>&1 &

echo "Fooocus started"
echo "Log file: /workspace/logs/fooocus.log"
deactivate
