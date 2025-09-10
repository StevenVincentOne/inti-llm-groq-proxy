# Changelog

All notable changes to the Inti LLM Groq Proxy will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-09-10

### Added
- IPv6 connectivity fix with `resolver ipv6=off` to eliminate upstream connection failures
- Connection pooling to Groq API with keepalive connections (10 connections, 60s timeout)
- Enhanced error handling with automatic upstream retries (2 attempts, 30s timeout)
- Comprehensive request/response logging with upstream timing metrics
- Built-in Docker health checks for container orchestration
- Variable-based proxy_pass for reliable DNS resolution
- Structured error pages with JSON responses
- Performance optimizations with nginx buffering and SSL session reuse

### Fixed
- **Critical**: Eliminated IPv6 "Network unreachable" errors that caused intermittent failures
- DNS resolution issues by forcing IPv4-only lookups with 300s cache
- Upstream connection stability with proper keepalive configuration
- SSL/TLS handshake optimization with session reuse
- Request timeout handling with appropriate retry logic

### Enhanced
- **Logging**: Added separate access/error logs for Groq API calls with timing data
- **Security**: Proper SSL verification settings and secure headers
- **Performance**: Nginx buffering and connection optimization
- **Monitoring**: Enhanced health endpoints with version information
- **Error Handling**: Graceful upstream failure handling with JSON error responses

### Technical Details
- Base image: nginx:1.25-alpine
- DNS resolvers: 1.1.1.1, 8.8.8.8 (IPv4 only)
- Connection settings: 30s connect timeout, 60s send/read timeout
- Upstream pool: 10 keepalive connections with 100 request limit
- Health check: 30s interval with 3 retries and 10s timeout

### Deployment
- Docker image: `intellipedia/inti-llm-groq-proxy:v1.2`
- Production tested on Docker Swarm with `unmute-net` overlay network
- Validated with Groq API integration and comprehensive endpoint testing
- Backward compatible with existing Unmute service configuration

### API Compatibility
- Full OpenAI API v1 compatibility maintained
- Support for all Groq models (llama3-8b-8192, llama3-70b-8192, mixtral-8x7b-32768, etc.)
- Transparent authentication handling with environment-based API key injection
- Health endpoints: `/api/build_info` and `/` for service discovery

### Testing
- Validated with `/v1/models` endpoint (200 OK responses)
- Chat completions tested with various models (200 OK with valid responses)
- Health endpoints verified for Docker Swarm integration
- Error handling tested with upstream failures and timeouts
- Performance testing with concurrent requests and connection pooling

## [1.1.0] - Previous Release

### Added
- Initial nginx-based proxy implementation
- Basic OpenAI API compatibility for `/v1/*` endpoints
- Environment variable-based API key injection
- Health endpoint at `/api/build_info`
- Docker container packaging

### Known Issues (Fixed in v1.2)
- Intermittent IPv6 connection failures to api.groq.com
- Limited error handling and retry logic
- Basic logging without upstream metrics
- No connection pooling optimization