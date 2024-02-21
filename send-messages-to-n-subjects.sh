#!/bin/bash

# Function to handle the signals
handle_signal() {
    echo "Signal caught, exiting the script..."
    exit
}

# Trap SIGINT (Ctrl+C) and SIGTSTP (Ctrl+Z)
trap handle_signal SIGINT SIGTSTP

# Number of times you want to run the command
N=1000000
COUNT=10
TIMEFORMAT='Took %R'
NATS_ARGS="-s nats://nats-3:4222 --user some_user --password some_passwd"

echo "Create LOGS stream..."
time docker exec -it nats-experiments-nats-cli-1 sh -c "nats stream add LOGS --subjects 'LOGS.>' --ack --replicas 3 --storage file $NATS_ARGS --defaults"

echo "Send $N logs..."
time {
    for (( i=1; i<=N; i++ ))
    do
        docker exec -it nats-experiments-nats-cli-1 sh -c "nats publish LOGS.${i}.logs --count $COUNT 'Message {{ Count }}-${i}: sdfgsdfgsdfgsdf' $NATS_ARGS"
    done
}

echo "Consume last per subject..."
time docker exec -it nats-experiments-nats-cli-1 sh -c "nats subscribe --stream=LOGS --last-per-subject --count $N $NATS_ARGS 'LOGS.>'"

# Calculate number of messages to consume and quit
TOTAL=$((N * COUNT))

echo "Consume all..."
time docker exec -it nats-experiments-nats-cli-1 sh -c "nats subscribe --stream=LOGS --all --count $TOTAL $NATS_ARGS 'LOGS.>'"
