from datetime import datetime

import requests

from config import Config
from excluded_dates import EXCLUDED_DATES


class MfApiClient:
    def __init__(self):
        self.base_url = Config.MFAPI_BASE_URL
        self.excluded_dates = {
            datetime.strptime(d, "%Y-%m-%d").date() for d in EXCLUDED_DATES
        }

    def fetch_nav_history(self, scheme_code: int) -> list[dict]:
        url = f"{self.base_url}/mf/{scheme_code}"
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json().get("data", [])

        # Filter out excluded dates
        filtered_data = []
        for entry in data:
            nav_date = datetime.strptime(entry["date"], "%d-%m-%Y").date()
            if nav_date not in self.excluded_dates:
                filtered_data.append(entry)

        return filtered_data

    def fetch_latest_nav(self, scheme_code: int) -> dict | None:
        url = f"{self.base_url}/mf/{scheme_code}/latest"
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json().get("data", [])
        return data[0] if data else None
