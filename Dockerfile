FROM ghcr.io/gleam-lang/gleam:v1.1.0-rc3-erlang-alpine

COPY gleam.toml manifest.toml /build/

RUN cd /build && gleam deps download

# Add project code
COPY src/ /build/src/

# Compile the project
RUN cd /build \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build

# Run the server

COPY docker-entrypoint.sh /app/docker-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD []

