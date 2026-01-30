#!/bin/bash
# Quick Setup & Run Guide
# ArogyaKrishi Backend - PostgreSQL Edition

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  ArogyaKrishi Backend - PostgreSQL Setup & Run${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Check if we're in the right directory
if [ ! -f "app/requirements.txt" ]; then
    echo -e "${YELLOW}⚠️  Please run this from the ArogyaKrishi root directory${NC}"
    exit 1
fi

# Step 1: Setup PostgreSQL
echo -e "${BLUE}Step 1: Setting up PostgreSQL...${NC}"
if command -v psql &> /dev/null; then
    echo -e "${GREEN}✓ PostgreSQL is installed${NC}"
    
    # Try to run setup script
    if [ -f "scripts/setup-postgres.sh" ]; then
        echo "Running setup script..."
        bash scripts/setup-postgres.sh
    else
        echo -e "${YELLOW}Setup script not found. Create database manually.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  PostgreSQL not installed. Install it first:${NC}"
    echo "  Ubuntu: sudo apt-get install postgresql postgresql-contrib"
    echo "  macOS: brew install postgresql@15"
    exit 1
fi

echo ""

# Step 2: Copy environment configuration
echo -e "${BLUE}Step 2: Setting up environment...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env from .env.example${NC}"
    else
        echo -e "${YELLOW}⚠️  .env.example not found${NC}"
    fi
else
    echo -e "${GREEN}✓ .env already exists${NC}"
fi

echo ""

# Step 3: Install Python dependencies
echo -e "${BLUE}Step 3: Installing Python dependencies...${NC}"
cd app
if pip install -r requirements.txt > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠️  Some dependencies may have failed to install${NC}"
fi
cd ..

echo ""

# Step 4: Initialize database
echo -e "${BLUE}Step 4: Initializing database...${NC}"
cd app
if python -m app.db.init_db > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Database tables created${NC}"
else
    echo -e "${YELLOW}⚠️  Database initialization may have failed${NC}"
    echo "Try manually: python -m app.db.init_db"
fi
cd ..

echo ""

# Step 5: Ready to start
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}To start the backend, run:${NC}\n"
echo -e "${GREEN}cd /home/dead/repos/ArogyaKrishi/app${NC}"
echo -e "${GREEN}PYTHONPATH=/home/dead/repos/ArogyaKrishi:\$PYTHONPATH \\${NC}"
echo -e "${GREEN}uvicorn main:app --reload --host 0.0.0.0 --port 8001${NC}\n"

echo -e "${YELLOW}Database Details:${NC}"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: arogya_krishi"
echo "  User: arogya_user"
echo "  Password: arogya_password\n"

echo -e "${YELLOW}Test the connection:${NC}"
echo -e "${GREEN}psql postgresql://arogya_user:arogya_password@localhost:5432/arogya_krishi${NC}\n"

echo -e "${YELLOW}Test the backend:${NC}"
echo -e "${GREEN}curl http://localhost:8001/health${NC}\n"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "For detailed docs, see: DATABASE_MIGRATION.md"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
