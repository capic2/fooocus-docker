variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "ashleykza"
}

variable "APP" {
    default = "fooocus"
}

variable "RELEASE" {
    default = "2.4.3"
}

variable "CU_VERSION" {
    default = "141"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "ashleykza/runpod-base"
}

variable "BASE_IMAGE_VERSION" {
    default = "1.8.0"
}

variable "CUDA_VERSION" {
    default = "12.4.1"
}

variable "TORCH_VERSION" {
    default = "2.3.1"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:${RELEASE}.post2"]
    args = {
        RELEASE = "${RELEASE}"
        BASE_IMAGE = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-cuda${CUDA_VERSION}-torch${TORCH_VERSION}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "${TORCH_VERSION}+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.27"
        FOOOCUS_VERSION = "v${RELEASE}"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
    }
}
