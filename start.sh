#!/bin/bash
set -e

cd /home/container/clipable
git reset --hard origin/main || echo "Failed to reset, continuing..."

# Pull latest changes from Git
echo ">>> Pulling latest changes from Git..."
git pull origin main || echo "Failed to pull changes, continuing..."

echo ">>> Starting server at $(date)"
echo ">>> Current user: $(whoami)"
echo ">>> Working directory: $(pwd)"

# Wait for MySQL ready
echo ">>> Waiting for MySQL at $DB_HOST:$DB_PORT ..."
until nc -z -w5 "$DB_HOST" "$DB_PORT"; do
  echo "MySQL not ready, retrying in 2s..."
  sleep 2
done
echo ">>> MySQL is ready."

# Start MinIO server in background
echo ">>> Starting MinIO server..."
./minio server minio_data &

# Wait for MinIO ready
echo ">>> Waiting for MinIO on port 9000..."
until nc -z -w5 127.0.0.1 9000; do
  echo "MinIO not ready, retrying in 2s..."
  sleep 2
done
echo ">>> MinIO is ready."

# Configure MinIO alias
echo ">>> Configuring MinIO alias..."
./mc alias set myminio http://127.0.0.1:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" || echo "Warning: mc alias set failed, may already exist."

# Create bucket if not exists
echo ">>> Creating bucket 'clipable' if not exists..."
./mc mb myminio/clipable || echo "Bucket exists or creation failed, continuing..."

# Build the backend
#echo ">>> Pulling latest changes from Git..."
#git pull origin main || echo "Failed to pull changes, continuing..."

echo ">>> Building backend..."
export GOTMPDIR=/home/container/tmp
cd ./backend || { echo "Backend directory not found!"; exit 1; }
go build -o ./clipable || { echo "Backend build failed!"; exit 1; }
cd ../..

# Start the backend binary
echo ">>> Starting backend..."
./clipable/clipable &

# Start the frontend
echo ">>> Starting frontend..."
cd ./clipable/frontend || { echo "Frontend directory not found!"; exit 1; }
npm install --legacy-peer-deps || { echo "Failed to install frontend dependencies"; exit 1; }
echo ">>> Starting frontend development server..."
npm run dev -- -p ${SERVER_PORT}

wait
