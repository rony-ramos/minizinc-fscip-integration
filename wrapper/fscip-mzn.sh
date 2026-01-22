#!/bin/bash

# Default values
THREADS=1
VERBOSE=0
SRCPATH=""
PARAMFILE="/tmp/fscip_params_$$.set"
DEBUGPARAMFILE="/tmp/fscip_debug_params.set"
SOLFILE="/tmp/fscip_sol_$$.txt"
LOGFILE="/tmp/fscip_run_log_$$.txt"

# Cleanup
trap "rm -f $PARAMFILE $LOGFILE" EXIT

# Parse arguments
args=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--parallel)
            THREADS="$2"
            shift 2
            ;;
        -a|--all-solutions)
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -s|--statistics)
            shift
            ;;
        *)
            if [[ "$1" == *.fzn ]]; then
                SRCPATH="$1"
            else
                args+=("$1")
            fi
            shift
            ;;
    esac
done

if [ -z "$SRCPATH" ]; then
    echo "Error: No .fzn file provided"
    exit 1
fi

# Create empty param file
touch $PARAMFILE
touch $LOGFILE

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Ensure log file exists
touch $LOGFILE

# Run FiberSCIP in background to capture PID
/usr/local/bin/fscip $PARAMFILE $SRCPATH -sth $THREADS -fsol $SOLFILE -q >> $LOGFILE 2>&1 &
FSCIP_PID=$!

if [ "$VERBOSE" -eq 1 ]; then
    # tail --pid follows the file until the process FSCIP_PID dies
    # This ensures we see the log output until the very end
    tail --pid=$FSCIP_PID -f "$LOGFILE" >&2
fi

# Wait for fscip to finish and capture exit code
wait $FSCIP_PID
RET=$?

# Check if solution file exists and parse it
if [ -f "$SOLFILE" ]; then
    # Pass SRCPATH (the .fzn file) to the normalizer script
    python3 "$SCRIPT_DIR/fscip-normalize.py" "$SOLFILE" "$SRCPATH"
    
    echo "----------"
    echo "=========="
    rm -f $SOLFILE
    rm -f $LOGFILE # Keep log for debugging if needed, or rely on tmp cleanup
else
    # Check log for unsatisfiability
    if grep -q "problem is infeasible" $LOGFILE; then
        echo "=====UNSATISFIABLE====="
    fi
fi
