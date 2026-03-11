FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y procps && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

COPY app/backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/worker/worker.py .

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

CMD ["python","-u","worker.py"]
