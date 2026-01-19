#!/bin/bash

# Standard MiniZinc paths in Linux
# Check for bundle installation first, then system-wide
if [ -d "/MiniZinc/share/minizinc" ]; then
    MZN_LIB_PATH="/MiniZinc/share/minizinc"
else
    MZN_LIB_PATH="/usr/local/share/minizinc"
fi

MZN_SOLVER_PATH="$MZN_LIB_PATH/solvers"

# Repository Root (Assuming this script is in docker/ folder)
REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

echo "Standardizing links for fscip integration..."

# Ensure target directories exist
mkdir -p "$MZN_SOLVER_PATH"

# Generate the MSC file with absolute paths to this repository
cat <<EOF > "$MZN_SOLVER_PATH/fscip.msc"
{
  "id": "org.scip.fscip",
  "name": "FiberSCIP (Parallel)",
  "version": "1.0.0",
  "executable": "$REPO_ROOT/wrapper/fscip-mzn.sh",
  "tags": ["fscip", "cp", "int", "float", "linear", "mzn"],
  "stdFlags": ["-a", "-p", "-s"],
  "supportsMzn": false,
  "supportsFzn": true,
  "needsSolns2Out": true,
  "isGUIApplication": false,
  "mznlib": "$REPO_ROOT/mznlib/fscip"
}
EOF

echo "Created solver configuration at: $MZN_SOLVER_PATH/fscip.msc"
echo "Integration complete. MiniZinc will now find fscip."

echo "Installation complete. MiniZinc can now find 'org.scip.fscip'."
