import argparse

from api_client import MfApiClient
from database import Database
from logger import get_logger
from nav_updater import NAVHistoryUpdater

logger = get_logger("main")


def main():
    parser = argparse.ArgumentParser(description="Update NAV data for mutual funds")
    parser.add_argument(
        "--mode",
        choices=["historical", "latest"],
        required=True,
        help="Mode of operation: historical (full history) or latest (today's NAV)",
    )

    args = parser.parse_args()
    logger.info("Starting NAV updater...")

    try:
        db = Database()
        api = MfApiClient()
        updater = NAVHistoryUpdater(db, api)

        if args.mode == "historical":
            logger.info("Updating historical NAV for all schemes")
            updater.update_all_scheme_nav_history()
        else:
            logger.info("Updating latest NAV for all schemes")
            updater.update_all_scheme_latest_nav()

        logger.info("NAV updater completed successfully")

    except Exception as e:
        logger.error(f"Error during NAV update: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()
