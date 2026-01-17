#!/bin/bash

# Default values
THREADS=1
SRCPATH=""
PARAMFILE="/tmp/fscip_params_$$.set"
SOLFILE="/tmp/fscip_sol_$$.txt"
LOGFILE="/tmp/fscip_run_log.txt"

# Cleanup
trap "rm -f $PARAMFILE" EXIT

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

# Run FiberSCIP
/usr/local/bin/fscip $PARAMFILE $SRCPATH -sth $THREADS -fsol $SOLFILE -q >> $LOGFILE 2>&1
RET=$?

# Check if solution file exists and parse it
if [ -f "$SOLFILE" ]; then
    # Pass SRCPATH (the .fzn file) to the normalizer script
    /usr/bin/python3 /opt/libminizinc/normalize_fscip_sol.py "$SOLFILE" "$SRCPATH"
    
    echo "----------"
    echo "=========="
    rm -f $SOLFILE
    # rm -f $LOGFILE # Keep log for debugging if needed, or rely on tmp cleanup
else
    # Check log for unsatisfiability
    if grep -q "problem is infeasible" $LOGFILE; then
        echo "=====UNSATISFIABLE====="
    fi
fi
