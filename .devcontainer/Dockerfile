FROM mcr.microsoft.com/devcontainers/python:3.11

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    gcc \
    g++ \
    make \
    cmake \
    libssl-dev \
    libffi-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Install Python dependencies (unified)
COPY requirements.unified.txt /tmp/requirements.unified.txt
RUN pip install --no-cache-dir -r /tmp/requirements.unified.txt

# Install Ollama (for local LLM)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set working directory
WORKDIR /workspace

# Copy unified build
COPY . /workspace/Constellation25

# Set environment
ENV PYTHONPATH="/workspace/Constellation25:${PYTHONPATH}"
ENV PATH="/workspace/Constellation25/bin:${PATH}"
ENV OLLAMA_HOST="0.0.0.0:11434"

# Expose ports
EXPOSE 8000 3000 11434

# Default command
CMD ["/workspace/Constellation25/boot.run.sh"]
