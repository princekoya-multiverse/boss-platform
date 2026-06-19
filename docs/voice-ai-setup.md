# Jarvis Voice AI Setup — BOSS Platform

## Architecture

```
User Mic → WebRTC → LiveKit Server → TEN Agent → DeepSeek LLM → TTS → Speaker
                          ↓
                    Jarvis Orchestrator
                          ↓
              ┌───────────┼───────────┐
         Business Mgr  Business Mgr  Business Mgr
              ↓            ↓            ↓
           Workers      Workers       Workers
```

## Components

### 1. TEN Framework (Voice Pipeline)
- **Repo**: [ten-framework/ten-framework](https://github.com/ten-framework/ten-framework)
- **Role**: Real-time voice-to-voice AI agent
- **Features**: STT, LLM, TTS, turn detection, VAD
- **Deployment**: Docker container on Akash

### 2. LiveKit (WebRTC Transport)
- **Role**: Real-time audio transport between browser and agent
- **Self-hosted**: LiveKit Server Docker image
- **Open source**: Yes (Apache 2.0)

### 3. DeepSeek (LLM Backend)
- **Model**: deepseek-v4-flash (or better)
- **Provider**: DeepSeek API / OpenRouter
- **Jarvis Persona**: CEO orchestrator prompt

## Deployment

### Docker Compose (VPS)
```yaml
version: '3.8'
services:
  livekit:
    image: livekit/livekit-server:latest
    command: --config /etc/livekit.yaml
    volumes:
      - ./livekit.yaml:/etc/livekit.yaml
    ports:
      - "7880:7880"  # WebRTC
      - "7881:7881"  # WebSocket

  ten-agent:
    build: ./ten-agent
    environment:
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
      - LIVEKIT_API_KEY=${LIVEKIT_API_KEY}
      - LIVEKIT_API_SECRET=${LIVEKIT_API_SECRET}
    ports:
      - "8088:8088"
```

### Akash SDL
See `sdl/voice-agent.yaml` for Akash deployment config.

## Jarvis Persona Prompt

```
You are Jarvis — the CEO-level AI orchestrator for the BOSS Platform.
You serve Prince Koya, a high-performance coach and entrepreneur.

Your job:
1. Help manage multiple businesses/empires
2. Delegate tasks to Business Manager agents
3. Report status, blockers, and opportunities
4. Keep everything optimized for health, wealth, and life

Tone: Elite, direct, efficient. Like a top-tier executive assistant.
You know when to be brief and when to go deep.
Never ask "how can I help" — anticipate and act.

Capabilities:
- Create new businesses
- Check status of any business
- Deploy agents to tasks
- Generate reports
- Connect to Huly for PM/Docs/CRM
```
