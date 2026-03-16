#!/bin/bash

VOLUME="/runpod-volume"
NETWORK_MODELS="/runpod-volume/ComfyUI/models"
COMFY_MODELS="/comfyui/models"

echo "Checking for network volume at $VOLUME..."

if [ -d "$VOLUME" ]; then
    echo "Network volume found!"
    if [ -d "$NETWORK_MODELS" ]; then
        echo "ComfyUI models found, creating symlinks..."
        for dir in checkpoints clip vae diffusion_models text_encoders video_models loras upscale_models embeddings; do
            if [ -d "$NETWORK_MODELS/$dir" ]; then
                rm -rf "$COMFY_MODELS/$dir"
                ln -sf "$NETWORK_MODELS/$dir" "$COMFY_MODELS/$dir"
                echo "Linked $dir"
            fi
        done
        if [ -d "/runpod-volume/ComfyUI/custom_nodes" ]; then
            for node in /runpod-volume/ComfyUI/custom_nodes/*/; do
                node_name=$(basename "$node")
                if [ "$node_name" != "__pycache__" ]; then
                    ln -sf "$node" "/comfyui/custom_nodes/$node_name"
                    echo "Linked custom node: $node_name"
                fi
            done
        fi
    fi
else
    echo "No network volume found, using default model paths"
fi

# Start ComfyUI in the background (same way the base image does it)
cd /comfyui
python3 main.py --listen 127.0.0.1 --port 8188 &

# Hand off to the RunPod handler
exec python3 -u /handler.py
