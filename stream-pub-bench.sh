#!/bin/bash

# Initialize variables
stream=""
stream_opts=""
msgs=""
cleanup=false

NATS_ARGS="-s nats://nats-3:4222 --user some_user --password some_passwd"

# Function to display usage
usage() {
    echo -e "\033[0;31mUsage: $0 --stream STREAM_NAME --msgs MESSAGE_COUNT [--stream-opts 'OPTIONS']\033[0m"
    echo "--stream: Name of the first stream to create"
    echo "--stream-opts: Additional options for creating a stream"
    echo "--msgs: How many messages to send to the stream"
    exit 1
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --stream) stream="$2"; shift ;;
        --stream-opts) stream_opts="$2"; shift ;;
        --msgs) msgs="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Check for mandatory options
if [[ -z "$stream" || -z "$msgs" ]]; then
    echo -e "\033[0;31mError: --stream and --msgs are mandatory.\033[0m"
    usage
fi

soft-stop() {
    kill $TAIL_PID
}
trap soft-stop SIGINT

echo -e "\033[0;34mCreate $stream stream...\033[0m"
docker exec -it nats-experiments-nats-cli-1 sh -c "nats stream add $stream $stream_opts $NATS_ARGS"

echo -e "\n\033[0;34mBenchmarking $stream...\033[0m"
# Running publishers process in background so it is possible to have subscribers in separate process - more reliable benchmark results
docker exec nats-experiments-nats-cli-1 sh -c "nats bench $stream --js --pub 4 --replicas 3 --size 2048 --msgs=$msgs --stream $stream --purge --no-progress $NATS_ARGS" &> publisher-output.log &
docker exec -it nats-experiments-nats-cli-1 sh -c "nats bench $stream --js --sub 8 --replicas 3 --size 2048 --msgs=$msgs --stream $stream --purge --no-progress --pull $NATS_ARGS"

sleep 1

echo -e "\n\033[0;Publisher output (ctrl+c when Pub stats visible):\033[0m\n\n"

tail -f publisher-output.log &
TAIL_PID=$!

wait $TAIL_PID

echo -e "\033[0;34mCleaning up...\033[0m"
docker exec -it nats-experiments-nats-cli-1 sh -c "nats stream rm -f $stream $NATS_ARGS"


echo -e "\033[0;32mDone!\033[0m"