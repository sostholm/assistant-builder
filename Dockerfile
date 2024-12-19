FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3.10 \
    python3-pip \
    python3.10-venv \
    python3.10-dev \
    wget \
    libportaudio2 \
    portaudio19-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN python3.10 -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --no-cache-dir --upgrade pip

WORKDIR /tmp

# Now when installing these packages, pyaudio and webrtcvad should build successfully
RUN git clone https://github.com/sostholm/assistant-voice-server.git \
    && . /opt/venv/bin/activate && pip install --no-cache-dir -r assistant-voice-server/requirements.txt \
    && git clone https://github.com/sostholm/assistant_process_audio.git \
    && pip install --no-cache-dir -r assistant_process_audio/requirements.txt \
    && git clone https://github.com/sostholm/assistant-conversation-backend.git \
    && pip install --no-cache-dir -r assistant-conversation-backend/requirements.txt \
    && git clone https://github.com/sostholm/assistant-admin-app.git \
    && pip install --no-cache-dir -r assistant-admin-app/requirements.txt

FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    python3.10 \
    libportaudio2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app
COPY supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 9001 8501
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
