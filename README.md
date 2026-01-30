# ArogyaKrishi

Crop disease detection and guidance system with a FastAPI backend and Flutter mobile app.

## Prerequisites

- Python 3.13
- PostgreSQL (local)
- Flutter SDK

## Backend setup

```bash
cd /home/dead/repos/ArogyaKrishi
bash scripts/setup-postgres.sh
cp .env.example .env
cd app
./venv/bin/pip install -r requirements.txt
PYTHONPATH=/home/dead/repos/ArogyaKrishi:$PYTHONPATH \
./venv/bin/python -m app.db.init_db
PYTHONPATH=/home/dead/repos/ArogyaKrishi:$PYTHONPATH \
./venv/bin/uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

Health check:

```bash
curl http://localhost:8001/health
```

## Mobile app setup

```bash
cd /home/dead/repos/ArogyaKrishi/mobile-app
flutter pub get
flutter run
```

## Project layout

```
app/          # FastAPI backend
mobile-app/   # Flutter mobile app
scripts/      # helper scripts
```
