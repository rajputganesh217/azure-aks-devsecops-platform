from flask_cors import CORS
import os
import time
import psycopg2
from flask import Flask, jsonify, request

app = Flask(__name__)
CORS(app)

# Read secrets from environment variables (Jenkins will provide them)
DB_HOST = os.environ["DB_HOST"]
DB_NAME = os.environ["DB_NAME"]
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5
    )


def wait_for_db(retries=10, delay=5):
    for _ in range(retries):
        try:
            conn = get_connection()
            conn.close()
            print("Database ready")
            return
        except Exception:
            print("Waiting for database...")
            time.sleep(delay)

    raise Exception("Database not ready")


def init_db():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id SERIAL PRIMARY KEY,
            shoe_id INTEGER,
            status TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    cur.close()
    conn.close()


@app.route("/")
def home():
    return jsonify({"message": "Shoe Store API running"})


@app.route("/health")
def health():
    try:
        conn = get_connection()
        conn.close()
        return jsonify({"status": "ok"}), 200
    except Exception:
        return jsonify({"status": "db-down"}), 500


@app.route("/buy", methods=["POST"])
def buy_shoe():
    data = request.get_json()

    shoe_id = data.get("shoe_id")

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "INSERT INTO orders (shoe_id, status) VALUES (%s,%s)",
        (shoe_id, "pending")
    )

    conn.commit()

    cur.close()
    conn.close()

    return jsonify({
        "message": "order created",
        "shoe_id": shoe_id
    })


if __name__ == "__main__":
    wait_for_db()
    init_db()

    app.run(
        host="0.0.0.0",
        port=5000
    )
