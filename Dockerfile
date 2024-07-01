ARG BASE_IMAGE
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create and use the Python venv
WORKDIR /
RUN python3 -m venv --system-site-packages /venv

# Clone the git repo of Fooocus and set version
ARG FOOOCUS_VERSION
RUN git clone https://github.com/lllyasviel/Fooocus.git && \
    cd /Fooocus && \
    git checkout ${FOOOCUS_VERSION}

# Install the dependencies for Fooocus
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
WORKDIR /Fooocus
ENV TORCH_INDEX_URL=${INDEX_URL}
ENV TORCH_COMMAND="pip install torch==${TORCH_VERSION} torchvision --index-url ${TORCH_INDEX_URL}"
ENV XFORMERS_PACKAGE="xformers==${XFORMERS_VERSION}"
RUN source /venv/bin/activate && \
    ${TORCH_COMMAND} && \
    pip3 install -r requirements_versions.txt --extra-index-url ${TORCH_INDEX_URL} && \
    pip3 install ${XFORMERS_PACKAGE} --index-url ${TORCH_INDEX_URL} &&  \
    sed '$d' launch.py > setup.py && \
    python3 -m setup && \
    deactivate

# Install CivitAI Model Downloader
ARG CIVITAI_DOWNLOADER_VERSION
RUN git clone https://github.com/ashleykleynhans/civitai-downloader.git && \
    cd civitai-downloader && \
    git checkout tags/${CIVITAI_DOWNLOADER_VERSION} && \
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
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
