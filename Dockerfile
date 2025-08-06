FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Build the release version
RUN cargo build --release

# Copy samply binary and make it executable
COPY artifacts/samply /usr/local/bin/samply
RUN chmod +x /usr/local/bin/samply

# Create a script to run the profiling
RUN echo '#!/bin/bash\n\
echo "-1" | tee /proc/sys/kernel/perf_event_paranoid\n\
samply record --presymbolicate --save-only -o /app/perf.json /app/target/release/samply_mre\n\
echo "Profiling completed. Output saved to /app/perf.json"\n\
# Copy to output directory if it exists\n\
if [ -d "/app/output" ]; then\n\
    cp /app/perf.json /app/output/\n\
fi' > /app/run_profiling.sh

RUN chmod +x /app/run_profiling.sh

# Set the entrypoint
ENTRYPOINT ["/app/run_profiling.sh"] 