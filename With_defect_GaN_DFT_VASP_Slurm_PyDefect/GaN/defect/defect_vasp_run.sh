for dir in */; do
    cd $dir
    # Submit the job and capture the job ID
    JOB_ID=$(sbatch srun.slurm | awk '{print $4}')
    cd ..

    # Wait for the job to complete
    echo "Waiting for job $JOB_ID to complete..."
    while squeue | grep -q "$JOB_ID"; do
        sleep 10  # Check every 10 seconds
    done
    echo "Job $JOB_ID completed."
done
