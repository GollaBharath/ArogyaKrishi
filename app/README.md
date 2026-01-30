# ArogyaKrishi Backend

FastAPI backend for plant disease detection system.

## Setup Instructions

### 1. Create Virtual Environment

```bash
# Navigate to the app directory
cd app

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate
```

### 2. Install Dependencies

```bash
# Ensure virtual environment is activated
pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Verify Installation

```bash
# Check Python version (3.10+ recommended)
python --version

# List installed packages
pip list
```

## Running the Server

```bash
# Development mode with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## Project Structure

```
app/
├── main.py           # FastAPI application entry point
├── api/              # API endpoints
├── services/         # Business logic services
├── models/           # Data models
├── utils/            # Utility functions
├── data/             # Static data and ML models
└── config.py         # Configuration management
```

## Environment Variables

Create a `.env` file in the app directory:

```env
# Application
ENV=development
DEBUG=True

# LLM API Keys (optional)
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here

# Model Configuration
USE_MOCK_MODEL=False
CONFIDENCE_THRESHOLD=0.7
```
