#!/bin/bash
set -e

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
./clipable/minio server minio_data &

# Wait for MinIO ready
echo ">>> Waiting for MinIO on port 9000..."
until nc -z -w5 127.0.0.1 9000; do
  echo "MinIO not ready, retrying in 2s..."
  sleep 2
done
echo ">>> MinIO is ready."

# Configure MinIO alias
echo ">>> Configuring MinIO alias..."
./clipable/mc alias set myminio http://127.0.0.1:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" || echo "Warning: mc alias set failed, may already exist."

# Create bucket if not exists
echo ">>> Creating bucket 'clipable' if not exists..."
./clipable/mc mb myminio/clipable || echo "Bucket exists or creation failed, continuing..."

# Start the backend binary
echo ">>> Starting backend..."
./clipable/clipable &

# Start the frontend
echo ">>> Starting frontend..."
cd frontend
npm run dev &

wait
