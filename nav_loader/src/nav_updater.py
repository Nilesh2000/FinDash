from api_client import MfApiClient
from database import Database
from logger import get_logger

logger = get_logger(__name__)


class NAVHistoryUpdater:
    def __init__(self, db: Database, api: MfApiClient):
        self.db = db
        self.api = api

    def update_scheme_nav(self, scheme_code: int):
        logger.info(f"Updating NAV history for scheme code {scheme_code}")
        mf_id = self.db.get_mf_id(scheme_code)
        if not mf_id:
            logger.warning(
                f"No mutual fund ID found for scheme code {scheme_code}, skipping..."
            )
            return
        nav_entries = self.api.fetch_nav_history(scheme_code)
        self.db.insert_nav_data(mf_id, nav_entries)

    def update_all_scheme_nav(self):
        scheme_codes = self.db.get_scheme_codes()
        for scheme_code in scheme_codes:
            self.update_scheme_nav(scheme_code)
