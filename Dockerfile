FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    perl \
    libexpat1-dev \
    libssl-dev \
    zlib1g-dev \
    pkg-config \
    curl \
    make \
    gcc \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Bootstrap cpanminus from the reviewed, checked-in installer, then Carton.
COPY bin/cpanm /usr/local/bin/cpanm-bootstrap
RUN perl /usr/local/bin/cpanm-bootstrap App::cpanminus \
    && cpanm Carton

WORKDIR /app

# Copy dependency files first (for Docker layer caching)
COPY cpanfile cpanfile.snapshot ./

# Install Perl deps (locked versions from snapshot)
RUN carton install --deployment

# Copy the rest of the source
COPY . .

EXPOSE 8000

# Default: build the site then serve it
CMD carton exec perl Run.pm && cd public && python3 -m http.server 8000
