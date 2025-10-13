FROM nginx:1.25-alpine

# Remove default site
RUN rm -rf /usr/share/nginx/html/*

# Copy custom static content
COPY index.html /usr/share/nginx/html/index.html

# Copy custom nginx config (if you have one)
# COPY nginx.conf /etc/nginx/nginx.conf

# Run Nginx as non-root user (default in official nginx image)


EXPOSE 80