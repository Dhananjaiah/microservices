FROM nginx:alpine

# Copy custom content
COPY index.html /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
