import os
import time
import psycopg2

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


def process_orders():
    print("Worker started and monitoring orders...")

    while True:
        try:
            conn = get_connection()
            cur = conn.cursor()

            cur.execute(
                "SELECT id, shoe_id FROM orders WHERE status='pending'"
            )

            orders = cur.fetchall()

            if not orders:
                print("No pending orders found")

            for order in orders:
                order_id = order[0]
                shoe_id = order[1]

                print(f"Processing order {order_id} for shoe {shoe_id}")

                time.sleep(2)

                cur.execute(
                    "UPDATE orders SET status='completed' WHERE id=%s",
                    (order_id,)
                )

                conn.commit()

                print(f"Order {order_id} completed")

            cur.close()
            conn.close()

        except Exception as e:
            print("Worker error:", e)

        time.sleep(5)


if __name__ == "__main__":
    process_orders()
