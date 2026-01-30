#!/bin/bash
# ArogyaKrishi Backend Startup Script
# This script properly sets up the environment and starts the backend

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The app directory
APP_DIR="$SCRIPT_DIR/app"

# The root directory (one level up from app)
ROOT_DIR="$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  ArogyaKrishi Backend - Starting${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Check if .env exists
if [ ! -f "$ROOT_DIR/.env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found${NC}"
    echo "Creating .env from .env.example..."
    cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
    echo -e "${GREEN}✓ .env created${NC}\n"
fi

# Check if virtual environment exists
if [ ! -d "$APP_DIR/venv" ]; then
    echo -e "${YELLOW}⚠️  Virtual environment not found${NC}"
    exit 1
fi

# Set environment variables
export PYTHONPATH="$ROOT_DIR:$PYTHONPATH"
export PORT="${PORT:-8001}"
export HOST="${HOST:-0.0.0.0}"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Root Directory: $ROOT_DIR"
echo "  App Directory: $APP_DIR"
echo "  PYTHONPATH: $PYTHONPATH"
echo "  Host: $HOST"
echo "  Port: $PORT"
echo ""

# Check if PostgreSQL is available (optional)
if command -v psql &> /dev/null; then
    if psql -U arogya_user -d arogya_krishi -c "SELECT 1" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL database is accessible${NC}\n"
    else
        echo -e "${YELLOW}⚠️  PostgreSQL database not accessible${NC}"
        echo "   Make sure PostgreSQL is running and initialized"
        echo "   Run: bash scripts/setup-postgres.sh\n"
    fi
fi

# Start the server
echo -e "${YELLOW}Starting FastAPI server...${NC}\n"
cd "$APP_DIR"
exec "$APP_DIR/venv/bin/uvicorn" app.main:app \
    --reload \
    --host "$HOST" \
    --port "$PORT"

