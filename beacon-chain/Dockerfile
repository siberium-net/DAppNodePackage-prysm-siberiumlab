FROM debian:bullseye-slim as binary

ARG TARGETARCH
ARG UPSTREAM_VERSION
ENV DOWNLOAD_URL https://github.com/prysmaticlabs/prysm/releases/download

RUN DEBIAN_FRONTEND=noninteractive \
  apt update && apt install --assume-yes --no-install-recommends wget ca-certificates && \
  echo ${DOWNLOAD_URL}/${UPSTREAM_VERSION}/beacon-chain-${UPSTREAM_VERSION}-linux-${TARGETARCH:-amd64} && \
  wget -q ${DOWNLOAD_URL}/${UPSTREAM_VERSION}/beacon-chain-${UPSTREAM_VERSION}-linux-${TARGETARCH:-amd64} -O /usr/local/bin/beacon-chain && \
  wget -q https://github.com/siberium-net/maineth2-networks/raw/master/shared/siberiumlab/genesis.ssz -O /tmp/genesis.ssz && \
  chmod +x  /usr/local/bin/beacon-chain

FROM debian:bullseye-slim

#Copy binaries from build stage
COPY --from=binary /usr/local/bin/beacon-chain /usr/local/bin/beacon-chain
COPY --from=binary /tmp/genesis.ssz /genesis.ssz
COPY jwtsecret.hex /jwtsecret
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apt update && \
  apt install -y curl ca-certificates file && \
  rm -rf /var/lib/apt/lists/* && \
  chmod +x /usr/local/bin/entrypoint.sh



ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

22222