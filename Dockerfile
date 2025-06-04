FROM php:8.2-fpm-alpine

# Instalar dependencias del sistema y extensiones de PHP
RUN apk add --no-cache \
    nginx \
    mysql-client \
    curl \
    git \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiar el código de la aplicación
COPY . .

# Instalar dependencias de Composer
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Generar la clave de la aplicación Laravel (si no existe)
RUN php artisan key:generate --ansi

# Ejecutar migraciones (opcional, considera si quieres que esto se haga automáticamente al levantar el contenedor)
# RUN php artisan migrate --force

# Limpiar cache y optimizar configuraciones
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Configurar permisos para los directorios de Laravel
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Exponer el puerto
EXPOSE 80

# Comando para iniciar el servidor web (usando Nginx y PHP-FPM)
CMD ["sh", "-c", "nginx && php-fpm"]