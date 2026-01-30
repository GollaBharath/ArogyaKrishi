#!/bin/bash
# PostgreSQL Setup Script for ArogyaKrishi
# This script sets up the PostgreSQL database and user for local development

set -e

echo "Setting up PostgreSQL for ArogyaKrishi..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}PostgreSQL is not installed. Please install it first:${NC}"
    echo "  Ubuntu/Debian: sudo apt-get install postgresql postgresql-contrib"
    echo "  macOS: brew install postgresql@15"
    exit 1
fi

echo -e "${YELLOW}Creating database and user...${NC}"

# Create database and user
sudo -u postgres psql << EOF
-- Create user if not exists
CREATE USER arogya_user WITH PASSWORD 'arogya_password';

-- Create database
CREATE DATABASE arogya_krishi OWNER arogya_user;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE arogya_krishi TO arogya_user;

-- Connect to the new database and grant schema privileges
\c arogya_krishi
GRANT ALL ON SCHEMA public TO arogya_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO arogya_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO arogya_user;

-- Enable UUID extension if needed in future
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOF

echo -e "${GREEN}✓ PostgreSQL setup complete!${NC}"
echo ""
echo "Connection details:"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: arogya_krishi"
echo "  User: arogya_user"
echo "  Password: arogya_password"
echo ""
echo "To verify the connection, run:"
echo "  psql postgresql://arogya_user:arogya_password@localhost:5432/arogya_krishi"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Copy .env.example to .env (DATABASE_URL is already configured)"
echo "2. Install Python dependencies: pip install -r app/requirements.txt"
echo "3. Run migrations: python -m alembic upgrade head (when available)"
echo "4. Start the backend: cd app && uvicorn main:app --reload"
