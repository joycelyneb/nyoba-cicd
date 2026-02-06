#!/bin/sh
# Recreate config file
rm -rf /usr/share/nginx/html/env-config.js
touch /usr/share/nginx/html/env-config.js

# Add assignment
echo "window._env_ = {" >> /usr/share/nginx/html/env-config.js
# Read the environment variable at runtime
echo "  REACT_APP_BACKEND_URL: \"$REACT_APP_BACKEND_URL\"," >> /usr/share/nginx/html/env-config.js
echo "}" >> /usr/share/nginx/html/env-config.js

# Script finishes, Nginx entrypoint continues

