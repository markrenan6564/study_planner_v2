# Use the official PHP image with Apache as the base image
FROM php:8.0-apache

# Install Node.js and npm
RUN apt update && apt install -y \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql

# Enable necessary Apache modules
RUN a2enmod rewrite proxy proxy_http ssl

# Copy PHP application files
COPY . /var/www/html

# Copy Node.js application files
COPY ./node /usr/src/app

# Copy the Apache configuration file to the correct location
COPY ./apache.prod.conf /etc/apache2/sites-available/000-default.conf

# Set the working directory for Node.js app
WORKDIR /usr/src/app

# Install Node.js dependencies
RUN npm install jspdf jspdf-autotable express http

# Set the working directory for PHP app
WORKDIR /var/www/html

# Expose the port specified by the PORT environment variable
EXPOSE 10000

# Set default environment variables for the database
ENV DB_HOST=127.0.0.1:3306
ENV DB_USERNAME=root
ENV DB_PASSWORD=my_secret_pw
ENV DB_NAME=study_planner

# Ensure Apache listens on the PORT environment variable
RUN echo "Listen ${PORT:-10000}" >> /etc/apache2/ports.conf

# Update the VirtualHost to listen on the PORT environment variable
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:10000>/' /etc/apache2/sites-available/000-default.conf

# Start both Apache and Node.js applications using JSON array for CMD
CMD ["sh", "-c", "apachectl -D FOREGROUND & node /usr/src/app/app.js"]
