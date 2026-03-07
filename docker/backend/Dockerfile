FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

COPY app/backend/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/backend/app.py .

EXPOSE 5000

CMD ["python", "app.py"]
