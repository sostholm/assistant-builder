# Use a base image with PyTorch and CUDA installed
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Install Python 3.10 and other dependencies
RUN apt-get update && apt-get install -y \
    supervisor \
    gcc \
    git \ 
    python3.10 \
    python3-pip \
    wget \
    libportaudio2 \
    portaudio19-dev \
    ffmpeg \
    avahi-daemon \
    libnss-mdns \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set 'python' command to point to Python 3.10
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Set the working directory in the container
WORKDIR /app

# Clone repository
RUN git clone https://github.com/sostholm/assistant-voice-server.git
RUN pip install -r assistant-voice-server/requirements.txt

RUN git clone https://github.com/sostholm/assistant_process_audio.git
RUN pip install -r assistant_process_audio/requirements.txt

RUN git clone https://github.com/sostholm/assistant-conversation-backend.git
RUN pip install -r assistant-conversation-backend/requirements.txt

RUN git clone https://github.com/sostholm/assistant-admin-app.git
RUN pip install -r assistant-admin-app/requirements.txt

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV STT_SERVER_URI=ws://localhost:9000/ws
ENV AI_AGENT_URI=ws://localhost:8000/ws

# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf

COPY assistant.service /etc/avahi/services/assistant.service

EXPOSE 9001 8501

# Start supervisord
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]