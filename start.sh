#!/bin/bash

VOLUME="/runpod-volume"
NETWORK_MODELS="/runpod-volume/ComfyUI/models"
COMFY_MODELS="/comfyui/models"

echo "Checking for network volume at $VOLUME..."
ls -la $VOLUME || echo "Volume not found or empty"

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
    else
        echo "No ComfyUI models dir found at $NETWORK_MODELS"
        echo "Contents of volume:"
        ls -la $VOLUME
    fi
else
    echo "No network volume found, using default model paths"
fi

exec python3 -u /handler.py
