from api_client import MfApiClient
from database import Database
from logger import get_logger
from nav_updater import NAVHistoryUpdater

logger = get_logger("main")


def main():
    logger.info("Starting NAV history updater...")
    db = Database()
    api = MfApiClient()
    updater = NAVHistoryUpdater(db, api)

    updater.update_all_scheme_nav()
    db.close()
    logger.info("NAV history updater completed successfully")


if __name__ == "__main__":
    main()
