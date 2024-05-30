FROM "ashleykza/runpod-base:1.3.0-cuda12.1.1-torch2.3.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create and use the Python venv
WORKDIR /
RUN python3 -m venv --system-site-packages /venv

# Clone the git repo of Fooocus and set version
RUN git clone https://github.com/lllyasviel/Fooocus.git && \
    cd /Fooocus && \
    git checkout v2.4.1

# Install the dependencies for Fooocus
WORKDIR /Fooocus
ENV TORCH_INDEX_URL=https://download.pytorch.org/whl/cu121
ENV TORCH_COMMAND="pip install torch==2.3.0+cu121 torchvision --index-url https://download.pytorch.org/whl/cu121"
ENV XFORMERS_PACKAGE="xformers==0.0.26.post1"
RUN source /venv/bin/activate && \
    pip install torch==2.3.0+cu121 torchvision --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install -r requirements_versions.txt --extra-index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install xformers==0.0.26.post1 --index-url https://download.pytorch.org/whl/cu121 &&  \
    sed '$d' launch.py > setup.py && \
    python3 -m setup && \
    deactivate

# Install CivitAI Model Downloader
RUN git clone https://github.com/ashleykleynhans/civitai-downloader.git && \
    cd civitai-downloader && \
    git checkout tags/2.1.0 && \
    cp download.py /usr/local/bin/download-model && \
    chmod +x /usr/local/bin/download-model && \
    cd .. && \
    rm -rf civitai-downloader

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy Fooocus config
COPY fooocus/config.txt /Fooocus/config.txt

# Set template version
ENV TEMPLATE_VERSION=2.4.1

# Set the venv path
ENV VENV_PATH=/workspace/venvs/fooocus

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
