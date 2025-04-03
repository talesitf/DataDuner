# DataDuner: A Functional ETL Project

A approach to ETL (Extract, Transform, Load) using functional programming principles with OCaml.

## Overview

DataDuner is a project that extracts order and item data from CSV files, processes it and loads the results into a SQLite database. The project is designed to be modular and reusable, allowing for easy integration with other data processing tasks.
The main aspects of this project are:

- **Functional Programming Principles**: Pure functions, immutability and composition.
- **Clean Architecture**: Separation of concerns, and pure/impure code boundaries.
- **ETL Pipeline**: Extracting data from CSV files (via HTTP), transforming it and loading it into a database (SQLite).

## Features

- Extracts data from CSV files via HTTP requests.
- Error handling during data extraction.
- Input of characteristics for data filtering.
- Inner join capability for relational data.
- Aggregation functions
- Monthly data summarization.
- SQLite database integration for data storage.
- Logging system.

- Dune build system for project management and building.

## Architecture

The architecture was built with the modularity and reusability in mind. The project is divided into several modules, each responsible for a specific part of the ETL process:
``` plaintext
etl_project/
├── bin/          # Main application entry point
│   ├── main.ml       # Main program file 
├── lib/          # Core library modules
│   ├── records.ml    # Data type definitions
│   ├── fe.ml         # Fetch (data aquiring)
│   ├── ex.ml         # Data parser/extractor
│   ├── tr.ml         # Data transformation
│   ├── sq.ml         # SQLite integration
│   └── logger.ml     # Logging functionality
├── data/         # Sample data files
└── test/         # Test suite
```

## Pure vs Impure Code

A good practice in functional programming is to separate pure and impure code. Pure functions are those that do not have side effects and always produce the same output for the same input. Impure functions, on the other hand, may have side effects (e.g., reading from a file, writing to a database, etc.). With that in mind, the project is divided into two main parts:

- **Pure modules**: Data parsing and transformation in `ex.ml`, `tr.ml`, and data type definitions in `records.ml`. 
Also, the `main.ml` module is pure, as it orchestrates the ETL process without side effects.
- **Impure modules**: Data fetching and database interaction in `fe.ml`, `sq.ml`, and logging in `logger.ml`.


## Technical Stack
- **Language**: OCaml
- **Build System**: Dune
- **HTTP Client**: Cohttp + Lwt
- **Database**: SQLite3 via Caqti
- **SQL Integration**: ppx_rapper

## Getting started

**Prerequisites**
- OCaml 4.14 or later
- Dune 3.0 or later
- Opam package manager

To get started with the project, follow these steps:

**1.** Clone the repository:
```bash
# Clone the repository
git clone https://github.com/username/DataDuner.git
cd DataDuner
```

**2.** Install dependencies:
```bash
# Install dependencies using opam
opam install csv lwt cohttp-lwt-unix cohttp ppx_rapper_lwt ppx_rapper caqti-driver-sqlite3 caqti-lwt
```

**3.** Build the project:
```bash
# Build the project using dune
dune build
```

**4.** Run the project:
```bash
# Run the main program
cd etl_project
dune exec etl_project <Status> <Origin>
```
Where `<Status>` and `<Origin>` are the characteristics you want to filter the data by, and:
- `<Status>` is one of: `Complete`, `Pending` or `Cancelled`.
- `<Origin>` is one of: `Physical` or `Online`.

## Data FLow

The data flow in the project is as follows:
1. **Extract**: Data is fetched from CSV files via HTTP requests using the `fe.ml` module. 

2. **Parse**: The data is then parsed into records using the `ex.ml` module.

3. **Filter**: The parsed data is filtered based on the characteristics provided by the user using the `tr.ml` module.

4. **Join**: Perform inner join on the filtered data using the `tr.ml` module.

5. **Transform**: Calculate the total prices and summarize the data monthly using the `tr.ml` module.

6. **Group**: Group the data by month and by order_id and calculate the total price using the `tr.ml` module.

7. **Load**: The transformed data is loaded into a SQLite database using the `sq.ml` module.

## Requirements

- Implementation in OCaml with map, reduce, and filter operations
- Separation of pure and impure functions
- Record-based data structures
- Helper functions for data loading

## Additional Features
- HTTP-based data extraction
- SQLite data storage
- Inner join implementation
- Monthly aggregation capability
- Logging system
- Comprehensive code documentation



Detailed repost in [Relatório](documents/Relarório%20Dataduner.pdf)