#!/bin/bash

# chmod +x setup.sh
# Script for initial setup of the Laravel project

set -e  # Stop script if any command fails

echo "================================================"
echo "  Laravel Project - Initial Setup"
echo "================================================"
echo ""

# 1. Check if .env exists
echo "Step 1: Checking .env file..."
if [ ! -f .env ]; then
    echo "⚠️  .env doesn't exist! Creating from .env.example..."
    cp .env.example .env
    echo "✓ Created .env from .env.example"
    echo "  Please review and adjust database credentials if needed!"
    echo ""
else
    echo "✓ .env already exists"
    echo ""
fi

# 2. Docker compose up
echo "Step 2: Starting Docker containers..."
docker compose up --build -d
echo "✓ Docker containers started"
echo ""

# Wait for MySQL to be ready
echo "Step 3: Waiting for MySQL to be ready..."
until docker exec mysql-laravel_project_starter mysqladmin ping -h "localhost" -u root -ppass1234 --silent 2>/dev/null; do
    echo "Waiting for MySQL..."
    sleep 2
done
echo "✓ MySQL is ready"
echo ""

# 3. Composer install
echo "Step 4: Installing Composer dependencies..."
if [ ! -d "vendor" ]; then
    docker exec php-laravel_project_starter composer install
    echo "✓ Composer dependencies installed"
else
    echo "✓ Vendor folder already exists (skipping)"
fi
echo ""

# 4. Generate application key
echo "Step 5: Generating application key..."
docker exec php-laravel_project_starter php artisan key:generate
echo "✓ Application key generated"
echo ""

# 5. Database creation
echo "Step 6: Creating database..."
docker exec mysql-laravel_project_starter mysql -uroot -ppass1234 -e "CREATE DATABASE IF NOT EXISTS \`laravel-project-starter_dev\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
echo "✓ Database created (or already exists)"
echo ""

# 6. Run migrations
echo "Step 7: Running migrations..."
docker exec php-laravel_project_starter php artisan migrate --force
echo "✓ Migrations executed"
echo ""

# 7. Set storage permissions
echo "Step 8: Setting storage and cache permissions..."
docker exec php-laravel_project_starter chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
docker exec php-laravel_project_starter chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
echo "✓ Permissions set"
echo ""

# 8. Clear and optimize cache
echo "Step 9: Clearing cache..."
docker exec php-laravel_project_starter php artisan config:clear
docker exec php-laravel_project_starter php artisan cache:clear
docker exec php-laravel_project_starter php artisan view:clear
echo "✓ Cache cleared"
echo ""

# 9. Install NPM dependencies (optional)
echo "Step 10: Installing NPM dependencies..."
if [ ! -d "node_modules" ]; then
    echo "⚠️  Run 'docker compose run --rm node' to install node packages"
    echo "  Or run 'npm install' locally if you have Node.js installed"
else
    echo "✓ Node modules already exist (skipping)"
fi
echo ""

echo "================================================"
echo "  ✅ Setup completed successfully!"
echo "================================================"
echo ""
echo "Application is available at:"
echo "  🌐 Web: http://localhost:8080"
echo "  🗄️ phpMyAdmin: http://localhost:8090"
echo "  ⚡ Vite dev server: http://localhost:5173"
echo ""
echo "Useful commands:"
echo "  sh up.sh                                    - Start containers"
echo "  sh down.sh                                  - Stop containers"
echo "  sh clear.sh                                 - Clear config cache"
echo "  sh migrate.sh                               - Run migrations"
echo "  sh pint.sh                                  - Run PHP CS Fixer (Pint)"
echo "  sh larastan.sh                              - Run Larastan (PHPStan for Laravel)"
echo "  sh test.sh                                  - Run tests"
echo "  sh qa.sh                                    - Run code quality checks (Pint, Larastan, Tests)"
echo "  sh composer-update.sh                       - Update Composer dependencies"
echo "  docker compose run --rm node                - Access node container"
echo ""
