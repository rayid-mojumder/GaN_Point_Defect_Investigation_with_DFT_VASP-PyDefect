#!/bin/bash

# Define the directory where the calculations were performed.
calc_dir="$(pwd)"

# File to store the total energies.
output_file="${calc_dir}/total_energies.txt"
echo "K-Points    Total Energy (eV)" > total_energies.txt

# Loop through the KPOINTS directories and extract energies.
for dir in ${calc_dir}/KPOINTS_*; do
  if [ -d "$dir" ] && [ -f "${dir}/OUTCAR" ]; then
    K_POINTS=$(basename "$dir" | sed 's/KPOINTS_//')
    ENERGY=$(grep "free  energy   TOTEN" "${dir}/OUTCAR" | tail -1 | awk '{print $5}')
    echo "$K_POINTS    $ENERGY" >> total_energies.txt
  fi
done


#command line execution
#chmod +x k_conv_test_1b.sh && sed -i 's/\r$//' k_conv_test_1b.sh && ./k_conv_test_1b.sh