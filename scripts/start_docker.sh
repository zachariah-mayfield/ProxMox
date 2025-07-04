#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Starting Docker Desktop..."
  open -a Docker

  # Wait until Docker daemon is ready (timeout 60 seconds)
  echo -n "Waiting for Docker to start"
  SECONDS=0
  until docker info > /dev/null 2>&1; do
    if [ $SECONDS -ge 60 ]; then
      echo "Timed out waiting for Docker to start."
      exit 1
    fi
    echo -n "."
    sleep 2
  done
  echo "Docker is running!"
else
  echo "Docker is already running."
fi
