from api_client import MfApiClient
from database import Database
from logger import get_logger

logger = get_logger(__name__)


class NAVHistoryUpdater:
    def __init__(self, db: Database, api: MfApiClient):
        self.db = db
        self.api = api

    def update_scheme_nav_history(self, scheme_code: int):
        """Update historical NAV data for a given scheme code"""
        logger.info(f"Updating NAV history for scheme code {scheme_code}")
        mf_id = self.db.get_mf_id(scheme_code)
        if not mf_id:
            logger.warning(
                f"No mutual fund ID found for scheme code {scheme_code}, skipping..."
            )
            return

        nav_entries = self.api.fetch_nav_history(scheme_code)
        self.db.insert_nav_data(mf_id, nav_entries)

    def update_scheme_latest_nav(self, scheme_code: int):
        """Update latest NAV data for a given scheme code"""
        logger.info(f"Updating latest NAV for scheme code {scheme_code}")
        mf_id = self.db.get_mf_id(scheme_code)
        if not mf_id:
            logger.warning(
                f"No mutual fund ID found for scheme code {scheme_code}, skipping..."
            )
            return

        latest_nav = self.api.fetch_latest_nav(scheme_code)
        if latest_nav:
            self.db.insert_nav_data(mf_id, [latest_nav])
        else:
            logger.warning(f"No latest NAV data found for scheme code {scheme_code}")

    def update_all_scheme_nav_history(self):
        """Update historical NAV data for all schemes"""
        scheme_codes = self.db.get_scheme_codes()
        for scheme_code in scheme_codes:
            self.update_scheme_nav_history(scheme_code)

    def update_all_scheme_latest_nav(self):
        """Update latest NAV data for all schemes"""
        scheme_codes = self.db.get_scheme_codes()
        for scheme_code in scheme_codes:
            self.update_scheme_latest_nav(scheme_code)
