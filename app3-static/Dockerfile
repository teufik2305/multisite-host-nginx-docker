# Use Nginx to serve static files
FROM nginx:alpine

# Copy static files to nginx html directory
COPY html/ /usr/share/nginx/html/

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Nginx runs automatically as the default command

