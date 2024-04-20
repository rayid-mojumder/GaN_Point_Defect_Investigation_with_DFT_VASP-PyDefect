#!/bin/bash

# Loop through directories
for dir in */; do
  # Check if OUTCAR exists
  if [[ -f "${dir}/OUTCAR" ]]; then
    # Check for ionic convergence
    if grep -q "reached required accuracy - stopping structural energy minimisation" "${dir}/OUTCAR"; then
      echo "Ionic convergence achieved in ${dir}"
    else
      echo "Ionic convergence NOT achieved in ${dir}"
    fi
  else
    echo "OUTCAR not found in ${dir}"
  fi
done
