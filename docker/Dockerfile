FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies (SCIP 10 Requirements + Build Tools)
# libgmp-dev, libmpfr-dev, libboost-all-dev: Required for SCIP 10 Exact Arithmetic and Rational mode
# liblapack-dev, libblas-dev: Linear algebra
# libtbb-dev: Threading Building Blocks
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  git \
  wget \
  libgmp-dev \
  libmpfr-dev \
  libboost-all-dev \
  liblapack-dev \
  libblas-dev \
  libtbb-dev \
  ca-certificates \
  zlib1g-dev \
  libreadline-dev \
  bison \
  flex \
  python3 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Installing SCIP Optimization Suite 10.0
# Reference: https://www.scipopt.org/download/release/scipoptsuite-10.0.0.tgz
# Features: SCIP, SoPlex, ZIMPL, PaPILO, GCG, UG (FiberSCIP)
RUN wget https://www.scipopt.org/download/release/scipoptsuite-10.0.0.tgz \
    && tar -xf scipoptsuite-10.0.0.tgz \
    && rm scipoptsuite-10.0.0.tgz \
    && cd scipoptsuite-10.0.0 \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
          -DAUTOBUILD=on \
          -DTPI=tny \
          -DSYM=snauty \
          -DLPS=spx \
          -DEXACTSOLVE=on \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make \
    && make install \   
    # Verificación y copiado manual de binarios de FiberSCIP si CMake no los mueve
    && if [ -f "bin/fscip" ]; then cp bin/fscip /usr/local/bin/; fi \
    && if [ -f "ug/bin/fscip" ]; then cp ug/bin/fscip /usr/local/bin/; fi

# Environment variables for SCIP
ENV SCIPOPTDIR="/usr/local"
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# Cloning MiniZinc Source Code
# The source code is cloned to /opt/libminizinc for manual modification and compilation.
RUN git clone https://github.com/MiniZinc/libminizinc.git /opt/libminizinc

RUN wget https://github.com/MiniZinc/MiniZincIDE/releases/download/2.9.4/MiniZincIDE-2.9.4-bundle-linux-x86_64.tgz \
    && tar -xf MiniZincIDE-2.9.4-bundle-linux-x86_64.tgz \
    && mv MiniZincIDE-2.9.4-bundle-linux-x86_64 /MiniZinc \
    && rm MiniZincIDE-2.9.4-bundle-linux-x86_64.tgz

# Configure MiniZinc Paths
ENV PATH="/MiniZinc/bin:$PATH"
ENV LD_LIBRARY_PATH="/MiniZinc/lib:$LD_LIBRARY_PATH"

# Configuration for MiniZinc to find fscip
WORKDIR /opt/minizinc-fscip-integration
COPY . .
RUN chmod +x docker/install.sh wrapper/fscip-mzn.sh && \
    ./docker/install.sh

# Workspace for mounting logs/tests
WORKDIR /workspace

CMD ["/bin/bash"]
