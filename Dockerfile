FROM nvcr.io/nvidia/pytorch:24.10-py3

# 作業ディレクトリを設定
WORKDIR /app

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ComfyUIをクローン
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# ComfyUI-Managerをクローン
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git ComfyUI/custom_nodes/ComfyUI-Manager

# custom_nodes.txtからcustom_nodesをクローン
COPY custom_nodes.txt /tmp/custom_nodes.txt
RUN while IFS= read -r repo_url; do \
    if [ ! -z "$repo_url" ] && [ "${repo_url#\#}" = "$repo_url" ]; then \
        repo_name=$(basename "$repo_url" .git); \
        echo "Cloning $repo_name from $repo_url"; \
        git clone "$repo_url" "ComfyUI/custom_nodes/$repo_name" || echo "Failed to clone $repo_url"; \
    fi \
    done < /tmp/custom_nodes.txt

# templateで使用するモデルをダウンロード
# RUN curl -L -o ComfyUI/models/checkpoints/v1-5-pruned-emaonly.safetensors \
#     https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

# ComfyUIの基本的な依存関係をインストール
RUN cd ComfyUI && \
    if [ -f requirements.txt ]; then \
        pip3 install -r requirements.txt; \
    else \
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
        pip3 install transformers accelerate diffusers[torch] xformers && \
        pip3 install pillow numpy opencv-python matplotlib psutil && \
        pip3 install safetensors aiohttp kornia spandrel soundfile tqdm; \
    fi

# ComfyUI-Managerの依存関係をインストール
RUN cd ComfyUI/custom_nodes/ComfyUI-Manager && \
    if [ -f requirements.txt ]; then \
        pip3 install -r requirements.txt; \
    fi

# 各custom_nodeの依存関係をインストール
RUN find ComfyUI/custom_nodes -name "requirements.txt" -exec pip3 install -r {} \; || true

# 起動スクリプトを作成
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'cd /app/ComfyUI' >> /app/start.sh && \
    echo '# ワークフローファイルが存在する場合、デフォルトテンプレートとして設定' >> /app/start.sh && \
    echo 'if [ -f /app/ComfyUI/workflow/steerable-motion_smooth-n-steady0525.json ]; then' >> /app/start.sh && \
    echo '  mkdir -p web/templates' >> /app/start.sh && \
    echo '  cp /app/ComfyUI/workflow/steerable-motion_smooth-n-steady0525.json web/templates/default.json' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo 'python3 main.py --listen 0.0.0.0' >> /app/start.sh && \
    chmod +x /app/start.sh

# ポートを公開
EXPOSE 8188

# ComfyUIを起動
WORKDIR /app/ComfyUI
CMD ["/app/start.sh"] 