import requests

from config import Config


class MfApiClient:
    def __init__(self):
        self.base_url = Config.MFAPI_BASE_URL

    def fetch_nav_history(self, scheme_code: int) -> list[dict]:
        url = f"{self.base_url}/mf/{scheme_code}"
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json().get("data", [])
        return data
