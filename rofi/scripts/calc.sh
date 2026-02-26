#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Type expression..."
  exit
fi

qalc -t "$1"
