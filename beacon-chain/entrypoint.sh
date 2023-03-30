#!/bin/bash

if [[ -n $CHECKPOINT_SYNC_URL ]]; then
  EXTRA_OPTS="--checkpoint-sync-url=${CHECKPOINT_SYNC_URL} --genesis-beacon-api-url=${CHECKPOINT_SYNC_URL} ${EXTRA_OPTS}"
else
  EXTRA_OPTS="--genesis-state=/genesis.ssz ${EXTRA_OPTS}"
fi

case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_SIBERIUMLAB in
"siberiumlab-geth.dnp.dappnode.eth")
  HTTP_ENGINE="http://siberiumlab-geth.dappnode:8551"
  ;;
"siberiumlab-nethermind.dnp.dappnode.eth")
  HTTP_ENGINE="http://siberiumlab-nethermind.dappnode:8551"
  ;;
"siberiumlab-besu.dnp.dappnode.eth")
  HTTP_ENGINE="http://siberiumlab-besu.dappnode:8551"
  ;;
"siberiumlab-erigon.dnp.dappnode.eth")
  HTTP_ENGINE="http://siberiumlab-erigon.dappnode:8551"
  ;;
*)
  echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_SIBERIUMLAB: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_SIBERIUMLAB"
  HTTP_ENGINE=$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_SIBERIUMLAB
  ;;
esac

# MEVBOOST: https://hackmd.io/@prysmaticlabs/BJeinxFsq
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_SIBERIUMLAB" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_SIBERIUMLAB" == "true" ]; then
  echo "MEVBOOST is enabled"
  MEVBOOST_URL="http://mev-boost.mev-boost-goerli.dappnode:18550"
  if curl --retry 5 --retry-delay 5 --retry-all-errors "${MEVBOOST_URL}"; then
    EXTRA_OPTS="--http-mev-relay=${MEVBOOST_URL} ${EXTRA_OPTS}"
  else
    echo "MEVBOOST is enabled but ${MEVBOOST_URL} is not reachable"
    curl -X POST -G 'http://my.dappnode/notification-send' --data-urlencode 'type=danger' --data-urlencode title="${MEVBOOST_URL} is not available" --data-urlencode 'body=Make sure the mevboost is available and running'
  fi
fi

exec -c beacon-chain \
  --datadir=/data \
  --rpc-host=0.0.0.0 \
  --accept-terms-of-use \
  --chain-id=110011 \
  --grpc-gateway-host=0.0.0.0 \
  --monitoring-host=0.0.0.0 \
  --p2p-tcp-port=$P2P_TCP_PORT \
  --p2p-udp-port=$P2P_UDP_PORT \
  --execution-endpoint=$HTTP_ENGINE \
  --grpc-gateway-port=3500 \
  --grpc-gateway-corsdomain=$CORSDOMAIN \
  --jwt-secret=/jwtsecret \
  $EXTRA_OPTS
