#!/bin/bash

# chmod +x qa.sh

set -e

echo "🔍 Running code quality checks..."
echo ""

echo "1️⃣  Running Pint (code style)..."
docker exec php-laravel_project_starter ./vendor/bin/pint --test
echo "✅ Code style check passed"
echo ""

echo "2️⃣  Running PHPStan (static analysis)..."
docker exec php-laravel_project_starter ./vendor/bin/phpstan analyse
echo "✅ Static analysis passed"
echo ""

echo "3️⃣  Running Tests..."
docker exec php-laravel_project_starter php artisan test
echo "✅ Tests passed"
echo ""

echo "🎉 All quality checks passed!"