# Treasury Cashflow Analytics - dbt Project

Production-ready dbt models for treasury management and cashflow analytics.

## Overview

This dbt project transforms raw financial data into analytics-ready models for:
- Monthly cashflow statements by category and company
- Daily cash position tracking with running balances
- Financial analysis and reporting

## Models

### Staging Layer (`models/staging/`)
- **stg_acdoca** - SAP ACDOCA universal journal entries (cleaned and standardized)
- **stg_bank_statements** - Bank statement transactions

### Marts Layer (`models/marts/`)
- **fct_cashflow_statement** - Monthly cashflow aggregated by category and company
- **fct_daily_cash_position** - Daily cash positions with running balances

## Data Flow

```
Raw Data (PostgreSQL)
    ↓
Staging Models (stg_*)
    - Data cleaning
    - Standardization
    - Business rules
    ↓
Mart Models (fct_*)
    - Aggregations
    - Calculations
    - Business logic
    ↓
Analytics & BI Tools
```

## Setup

### Prerequisites
- Python 3.8+
- PostgreSQL database
- dbt-postgres

### Installation

```bash
# Install dbt
pip install dbt-postgres

# Install project dependencies
dbt deps
```

### Configuration

1. Copy the profiles template:
```bash
cp profiles.yml.example profiles.yml
```

2. Edit `profiles.yml` with your database credentials

3. Test connection:
```bash
dbt debug
```

### Running the Project

```bash
# Run all models
dbt run

# Run tests
dbt test

# Build everything (run + test)
dbt build

# Generate documentation
dbt docs generate
dbt docs serve
```

## Project Structure

```
treasury_dbt/
├── models/
│   ├── staging/          # Source data cleaning
│   │   ├── stg_acdoca.sql
│   │   ├── stg_bank_statements.sql
│   │   └── schema.yml
│   └── marts/            # Business logic
│       ├── fct_cashflow_statement.sql
│       ├── fct_daily_cash_position.sql
│       └── schema.yml
├── tests/                # Custom data tests
├── macros/               # Reusable SQL functions
├── dbt_project.yml       # Project configuration
└── profiles.yml          # Database connection (not in git)
```

## Key Features

- ✅ Modular design with clear staging → marts flow
- ✅ Comprehensive data quality tests
- ✅ Auto-generated documentation
- ✅ Incremental models for performance
- ✅ Production-ready schemas

## Dependencies

- dbt-core >= 1.7.0
- dbt-postgres >= 1.7.0
- dbt-utils >= 1.1.0

## Documentation

Run `dbt docs generate && dbt docs serve` to view:
- Data lineage (DAG)
- Model descriptions
- Column-level documentation
- Test results

## Owner

**Project**: Treasury Cashflow Analytics  
**Created**: January 2026  
**Status**: Production Ready
