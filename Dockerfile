# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN git clone https://github.com/WhatDreamsCost/WhatDreamsCost-ComfyUI /comfyui/custom_nodes/WhatDreamsCost-ComfyUI && cd /comfyui/custom_nodes/WhatDreamsCost-ComfyUI && (git checkout 5cae3c00186ff2eb79771070f05a2c4e02f329bb 2>/dev/null || (git fetch origin 5cae3c00186ff2eb79771070f05a2c4e02f329bb --depth=1 && git checkout 5cae3c00186ff2eb79771070f05a2c4e02f329bb) || echo "WARN: commit 5cae3c00186ff2eb79771070f05a2c4e02f329bb unreachable in https://github.com/WhatDreamsCost/WhatDreamsCost-ComfyUI, falling back to default branch HEAD")

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors' --relative-path models/upscale_models --filename 'ltx-2-spatial-upscaler-x2-1.0.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
