# MiniZinc - FiberSCIP (fscip) Integration

This repository provides the necessary files to integrate **FiberSCIP (fscip)**, the parallel version of the SCIP solver, into MiniZinc.

## Architecture

Traditional MiniZinc solvers often integrate via dynamic libraries (in-memory). However, FiberSCIP (fscip) operates as an independent orchestrator using the UG (Ubiquity Generator) framework, requiring an external process execution.

### Key Components

- **`solvers/fscip.msc`**: MiniZinc solver configuration file. It uses relative paths to point to the wrapper and library.
- **`wrapper/fscip-mzn.sh`**: A bash wrapper that:
  - Generates parameter files required by fscip.
  - Translates MiniZinc flags (like `-p` for threads) to fscip flags (`-sth`).
  - Executes the `fscip` binary.
- **`wrapper/fscip-normalize.py`**: A Python script that parses the raw, non-standard fscip log and converts it back into FlatZinc solution format (`var = value;`) so MiniZinc can process it.
- **`mznlib/fscip/`**: Contains redefinitions and linearizations optimized for SCIP.

## Path Standardization

The integration is designed to be **sustainable and adaptable** across different environments (local development, Docker, etc.):

1. **Relative MSC Paths**: `fscip.msc` uses relative indexing (`../wrapper/` and `../mznlib/`) to find its components, making the repository portable.
2. **Dynamic Script Location**: The shell wrapper (`fscip-mzn.sh`) automatically determines its own directory to locate the Python normalizer, avoiding hardcoded `/opt/` or `/usr/` paths.
3. **Linux Ready**: All paths and scripts are standardized for POSIX-compliant environments, ideal for Docker-based workflows.

## Installation (Docker)

The fastest way to get started is using the provided Docker environment.

```bash
cd docker
docker compose up --build -d
docker exec -it minizinc-fscip-integration /bin/bash
```

The `install.sh` script (run automatically during image build) generates a `fscip.msc` file that links MiniZinc to the scripts in this repository.

## Usage & Examples

Once inside the container, you can use FiberSCIP like any other MiniZinc solver.

### 1. Basic Execution
Run a model using the `fscip` identifier:
```bash
minizinc --solver fscip workspace/model.mzn workspace/data.dzn
```

### 2. Parallelism (The main benefit)
FiberSCIP is built for parallel execution. Use the `-p` or `--parallel` flag to allocate cores:
```bash
# Run with 4 threads
minizinc --solver fscip -p 4 workspace/complex_model.mzn
```

### 3. Verification
To verify that MiniZinc correctly detects the solver:
```bash
minizinc --solvers | grep fscip
```

## How it works (Internals)

FiberSCIP doesn't speak "FlatZinc" natively for output. This integration uses a **Normalization Layer**:
1. **Wrapper (`fscip-mzn.sh`)**: Captures MiniZinc intent, prepares SCIP settings, and executes the parallel binary.
2. **Normalizer (`fscip-normalize.py`)**: Post-processes the UG/FiberSCIP logs to extract variable assignments and format them as standard FlatZinc solutions (`name = value;`), allowing MiniZinc to validate and display them correctly.
