# Inti LLM Groq Proxy

**Status**: ✅ **PRODUCTION READY** - IPv6 Issues Resolved  
**Current Version**: v1.2-inline-config (Working)  
**Last Updated**: 2025-09-10  
**Model Support**: ✅ **gpt-oss-20b validated and working**

An Nginx-based HTTP proxy that provides OpenAI-compatible API access to Groq's language models. This proxy handles authentication, eliminates IPv6 connectivity issues, and provides health monitoring for Docker Swarm deployments.

## 🎯 Current Working Solution

**Recommended Approach**: **Inline configuration** in Docker Swarm
- ✅ **Currently deployed and functional**
- ✅ **IPv6 connectivity issues resolved**  
- ✅ **gpt-oss-20b model working end-to-end**
- ✅ **No Docker entrypoint issues**

## Overview

This proxy accepts HTTP requests in OpenAI API format and forwards them to Groq's OpenAI-compatible API endpoint, automatically injecting the required authorization headers. It eliminates the need for API key management in client applications and resolves networking issues.

## Features

✅ **OpenAI API Compatibility** - Drop-in replacement for OpenAI API endpoints  
✅ **IPv6 Issue Resolution** - Eliminates IPv6 upstream connection failures  
✅ **Automatic Authentication** - Handles Groq API key injection transparently  
✅ **Health Monitoring** - HTTP health endpoint for service discovery  
✅ **Performance Optimized** - Connection pooling, keepalive, and error handling  
✅ **Docker Swarm Ready** - Designed for container orchestration  
✅ **Comprehensive Logging** - Request/response logging with upstream metrics  

## Quick Start

### Docker Hub

```bash
docker pull intellipedia/inti-llm-groq-proxy:v1.2
```

### Environment Variables

- `GROQ_API_KEY` or `OPENAI_API_KEY`: Groq API key (required)

### Docker Compose Example

```yaml
version: '3.8'
services:
  llm-proxy:
    image: intellipedia/inti-llm-groq-proxy:v1.2
    ports:
      - "8080:8080"
    environment:
      - GROQ_API_KEY=your_groq_api_key_here
    networks:
      - unmute-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/build_info"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Docker Swarm Service

```bash
docker service create \
  --name unmute_unmute_llm \
  --network unmute-net \
  --env GROQ_API_KEY="your_api_key" \
  intellipedia/inti-llm-groq-proxy:v1.2
```

## API Reference

### Base URL

**Endpoint**: `http://localhost:8080`

### OpenAI-Compatible Endpoints

**Models List**: `GET /v1/models`
```bash
curl http://localhost:8080/v1/models
```

**Chat Completions**: `POST /v1/chat/completions`
```bash
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3-8b-8192",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 100
  }'
```

### Health Endpoints

**Health Check**: `GET /api/build_info`
```json
{
  "status": "ok", 
  "service": "llm-groq-proxy",
  "version": "v1.2"
}
```

**Root Health**: `GET /`
```json
{"status": "ok", "service": "llm-groq-proxy"}
```

## Architecture

```
Client/Unmute → LLM Proxy → Groq API (https://api.groq.com/openai/v1/*)
                    ↓
            Automatic API Key Injection
            IPv4-Only DNS Resolution
            Connection Pooling & Error Handling
```

### Key Improvements (v1.2)

1. **IPv6 Fix**: `resolver 1.1.1.1 8.8.8.8 ipv6=off` eliminates connection failures
2. **Connection Pooling**: Upstream keepalive connections for better performance
3. **Enhanced Error Handling**: Automatic retries with configurable timeouts
4. **Comprehensive Logging**: Request timing, upstream metrics, and error tracking
5. **Variable-based Proxy Pass**: Ensures proper DNS resolution and IPv4 routing

## Configuration

### Nginx Features

- **DNS Resolution**: IPv4-only with 300s cache to prevent IPv6 issues
- **Connection Pooling**: 10 keepalive connections to Groq API
- **Timeout Settings**: 30s connect, 60s send/read timeouts
- **Retry Logic**: 2 upstream attempts with 30s timeout
- **Request Logging**: Detailed access logs with upstream timing

### Supported Models

All Groq models available via their API:
- `llama3-8b-8192` (Llama 3 8B)
- `llama3-70b-8192` (Llama 3 70B)  
- `mixtral-8x7b-32768` (Mixtral 8x7B)
- `gemma-7b-it` (Gemma 7B)
- And more...

## Development

### Local Build

```bash
git clone https://github.com/StevenVincentOne/inti-llm-groq-proxy.git
cd inti-llm-groq-proxy
docker build -t inti-llm-groq-proxy .
```

### Dependencies

- Nginx 1.25-alpine (Base image)
- curl (Health checks)
- gettext (Environment variable substitution)

### Testing

```bash
# Build and run locally
docker build -t llm-proxy-test .
docker run -p 8080:8080 -e GROQ_API_KEY="your_key" llm-proxy-test

# Test endpoints
curl http://localhost:8080/api/build_info
curl http://localhost:8080/v1/models
```

## Production Deployment

### System Requirements

- Docker Swarm or Docker Compose
- Network connectivity to api.groq.com (IPv4)
- Valid Groq API key
- Port 8080 available

### Performance

- **Latency**: Typical chat completion < 1-2 seconds
- **Throughput**: Handles concurrent connections via nginx
- **Connection Pooling**: Reduces upstream connection overhead
- **Error Recovery**: Automatic retry on upstream failures

### Monitoring

Health checks available at:
- `GET /api/build_info` - Service status with version
- `GET /` - Simple health check
- Docker health check: Built-in container health monitoring

### Logging

- **Access Log**: All requests with timing data
- **Error Log**: Upstream connection issues and errors
- **Groq-specific Logs**: Separate access/error logs for Groq API calls

## Integration

### Unmute Configuration

```bash
# Set in Unmute service environment
KYUTAI_LLM_URL=http://unmute_llm:8080
KYUTAI_LLM_MODEL=llama3-8b-8192
```

### Client Usage

The proxy is fully compatible with OpenAI SDK:

```python
from openai import AsyncOpenAI

client = AsyncOpenAI(
    api_key="not-needed",  # Proxy handles authentication
    base_url="http://unmute_llm:8080/v1"
)

response = await client.chat.completions.create(
    model="llama3-8b-8192",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## Troubleshooting

**Connection Issues**:
- Verify Docker network configuration (`unmute-net`)
- Check DNS resolution: `nslookup api.groq.com`
- Ensure IPv4 connectivity to api.groq.com

**Authentication Issues**:
- Verify `GROQ_API_KEY` environment variable is set
- Check API key validity: `curl -H "Authorization: Bearer $KEY" https://api.groq.com/openai/v1/models`
- Review proxy logs for authentication errors

**Performance Issues**:
- Monitor upstream connection timing in logs
- Check Groq API status and rate limits
- Verify connection pooling is working (keepalive logs)

**IPv6 Errors (Legacy)**:
- v1.2+ eliminates IPv6 issues with `ipv6=off` resolver
- Upgrade from older versions if seeing "Network unreachable" errors

## Version History

### v1.2 (2025-09-10)
- ✅ **IPv6 Fix**: Eliminated IPv6 connection failures with IPv4-only DNS resolution
- ✅ **Performance**: Added connection pooling and keepalive to Groq API
- ✅ **Error Handling**: Enhanced retry logic and timeout configuration
- ✅ **Logging**: Comprehensive request/response logging with upstream metrics
- ✅ **Health Checks**: Built-in Docker health monitoring
- ✅ **Production Ready**: Tested and validated with comprehensive error handling

### v1.1 (Previous)
- Basic nginx proxy functionality
- OpenAI API compatibility
- Environment-based API key injection

## License

This project is part of the Inti platform.

## Contributing

This proxy is designed specifically for the Inti/Unmute ecosystem. For issues or feature requests, please refer to the main Inti documentation.

---

For detailed deployment instructions and operational guidance, see: [LLM-Groq-Proxy-Implementation.md](LLM-Groq-Proxy-Implementation.md)