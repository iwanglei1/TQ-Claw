#!/bin/sh
# Substitute TQCLAW_PORT in supervisord template and start supervisord.
# Default port 8088; override at runtime with -e TQCLAW_PORT=3000.
set -e
export TQCLAW_PORT="${TQCLAW_PORT:-8088}"
envsubst '${TQCLAW_PORT}' \
  < /etc/supervisor/conf.d/supervisord.conf.template \
  > /etc/supervisor/conf.d/supervisord.conf
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
