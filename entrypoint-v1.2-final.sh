#!/bin/sh
set -e

echo "=== LLM Groq Proxy v1.2-final Starting ==="

# Validate required environment variables
API_KEY="${GROQ_API_KEY:-${OPENAI_API_KEY:-}}"

if [ -z "$API_KEY" ]; then
    echo "ERROR: No API key found. Set GROQ_API_KEY or OPENAI_API_KEY environment variable."
    exit 1
fi

echo "INFO: API key configured (${#API_KEY} characters)"
echo "INFO: Starting LLM Groq Proxy v1.2-final with IPv6 fixes and gpt-oss-20b support"

# Substitute environment variables in nginx config template
echo "INFO: Generating nginx configuration with API key..."
envsubst '${GROQ_API_KEY}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Test nginx configuration
echo "INFO: Validating nginx configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "ERROR: Nginx configuration test failed"
    exit 1
fi

echo "INFO: Configuration validated successfully"
echo "INFO: Ready to proxy requests to Groq API with gpt-oss-20b model support"

# Start nginx in foreground
exec nginx -g "daemon off;"