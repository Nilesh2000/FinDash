from datetime import datetime

import psycopg2
from psycopg2.extensions import connection

from config import Config
from logger import get_logger

logger = get_logger(__name__)


class Database:
    def __init__(self):
        self.conn: connection = psycopg2.connect(
            host=Config.DB_HOST,
            port=Config.DB_PORT,
            user=Config.DB_USER,
            password=Config.DB_PASSWORD,
            database=Config.DB_NAME,
        )
        logger.info("Database connection established")

    def get_scheme_codes(self) -> list[int]:
        with self.conn.cursor() as cursor:
            cursor.execute("SELECT scheme_code FROM mutual_funds")
            result = cursor.fetchall()
            scheme_codes = [row[0] for row in result]
            logger.debug(f"Retrieved {len(scheme_codes)} scheme codes")
        return scheme_codes

    def get_mf_id(self, scheme_code: int) -> int | None:
        with self.conn.cursor() as cursor:
            cursor.execute(
                "SELECT id FROM mutual_funds WHERE scheme_code = %s", (scheme_code,)
            )
            result = cursor.fetchone()
        return result[0] if result else None

    def insert_nav_data(self, mf_id: int, nav_entries: list[dict]) -> None:
        with self.conn.cursor() as cursor:
            query = """
            INSERT INTO nav_history (mf_id, date, nav)
            VALUES (%s, %s, %s)
            ON CONFLICT (mf_id, date) DO UPDATE SET nav = EXCLUDED.nav
            """
            for entry in nav_entries:
                nav_date = datetime.strptime(entry["date"], "%d-%m-%Y").date()
                nav_value = float(entry["nav"])
                cursor.execute(query, (mf_id, nav_date, nav_value))
            logger.debug(
                f"Inserted {len(nav_entries)} NAV entries for mutual fund {mf_id}"
            )

    def insert_specific_nav(self, scheme_code: int, date: str, nav: float):
        with self.conn.cursor() as cursor:
            mf_id = self.get_mf_id(scheme_code)
            if mf_id:
                cursor.execute(
                    "INSERT INTO nav_history (mf_id, date, nav) VALUES (%s, %s, %s)",
                    (mf_id, date, nav),
                )
            self.conn.commit()

    def close(self):
        self.conn.close()
        logger.info("Database connection closed")
