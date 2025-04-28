# FinDash

FinDash is a financial dashboard application that provides portfolio management and analytics capabilities. The project uses PostgreSQL for data storage, Metabase for data visualization, and pgAdmin for database management.

## Features

- Portfolio data management
- Interactive data visualization with Metabase
- Database management with pgAdmin
- Containerized deployment
- Mutual Fund NAV (Net Asset Value) tracking with historical and latest data

## Prerequisites

- Docker
- Docker Compose
- Make (optional, for using Makefile commands)
- Python 3.x (for nav_loader)
- PostgreSQL client libraries (for nav_loader)

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd FinDash
   ```

2. Create and configure the `.env` file with the following variables:

   ```env
   # PostgreSQL Configuration
   POSTGRES_USER=your_postgres_user
   POSTGRES_PASSWORD=your_postgres_password
   POSTGRES_DB=portfolio

   # pgAdmin Configuration
   PGADMIN_DEFAULT_EMAIL=your_email@example.com
   PGADMIN_DEFAULT_PASSWORD=your_pgadmin_password

   # Metabase Configuration
   MB_DB_TYPE=postgres
   MB_DB_DBNAME=metabase
   MB_DB_PORT=5432
   MB_DB_USER=your_postgres_user
   MB_DB_PASSWORD=your_postgres_password
   MB_DB_HOST=postgres
   JAVA_TIMEZONE=UTC

   # NAV Loader Configuration
   MFAPI_BASE_URL=https://www.mfapi.in
   ```

3. Start the services:
   ```bash
   make up
   ```
   or
   ```bash
   docker-compose up
   ```

4. Access the services:
   - Metabase: http://localhost:3000
   - pgAdmin: http://localhost:5050
   - PostgreSQL: localhost:5432

## Project Structure

```
FinDash/
├── docker-entrypoint-initdb.d/      # Database initialization scripts
├── nav_loader/                      # Navigation loader component
│   ├── src/                         # Source code
│   │   ├── main.py                  # Main entry point
│   │   ├── api_client.py            # Mutual fund API client
│   │   ├── database.py              # Database operations
│   │   ├── nav_updater.py           # NAV update logic
│   │   ├── config.py                # Configuration
│   │   ├── logger.py                # Logging setup
│   │   ├── excluded_dates.py        # Dates to exclude from NAV data
│   │   └── specific_nav_entries.py  # Manual NAV entries
│   └── requirements.txt             # Python dependencies
├── docker-compose.yaml              # Docker Compose configuration
├── Makefile                         # Make commands
├── portfolio.sql                    # Portfolio database schema
└── README.md                        # This file
```

## Available Commands

- `make up`: Start all services
- `make down`: Stop all services and remove volumes
- `make backup`: Create database backups

## NAV Loader Component

The `nav_loader` is a Python-based component that synchronizes Mutual Fund NAV data with your portfolio database. It fetches data from the https://www.mfapi.in/ service and stores it in your PostgreSQL database.

### Setup

1. Create and activate a virtual environment:
   ```bash
   # Create virtual environment
   python -m venv .venv

   # Activate virtual environment
   # On macOS/Linux:
   source .venv/bin/activate
   # On Windows:
   .venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   cd nav_loader
   pip install -r requirements.txt
   ```

### Features

- Fetches historical NAV data for all schemes in your portfolio
- Updates latest NAV values for all schemes
- Handles excluded dates (holidays, etc.)
- Supports manual NAV entries for specific dates
- Comprehensive logging

### Usage

1. Run the NAV loader:
   ```bash
   python src/main.py --mode [historical|latest]
   ```

   - `historical`: Fetches complete NAV history for all schemes
   - `latest`: Updates only the most recent NAV values

### Configuration

The component can be further configured through:
- Environment variables (see above)
- `excluded_dates.py`: List of dates to exclude from NAV data
- `specific_nav_entries.py`: Manual NAV entries for specific dates

### Data Flow

1. Reads scheme codes from the database
2. Fetches NAV data from https://www.mfapi.in/
3. Filters out excluded dates
4. Updates the database with new NAV values
5. Logs all operations for monitoring

## Database Management

The project includes database backup functionality. To create a backup:

```bash
make backup
```

This will create backup files in the `docker-entrypoint-initdb.d/` directory:
- `02-schema.sql`: Database schema
- `03-data.sql`: Database data
- `04-metabase_dump.sql`: Metabase configuration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
