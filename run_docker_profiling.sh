#!/bin/bash

# Create output directory
mkdir -p docker_output

# Build the Docker image
echo "Building Docker image..."
docker build -t samply-profiler .

# Run the container with privileged mode and volume mount for output
echo "Running profiling in Docker..."
docker run --privileged \
    -v $(pwd)/docker_output:/app/output \
    samply-profiler

echo "Profiling completed! Check docker_output/perf.json" 