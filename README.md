# NATS JetStream experiments

Starting the cluster:

```bash
docker compose -f docker-compose.yml up -d
```

## Experiment 1 - number of subjects

Check limits of number of subjects in single stream.

Script usage:
```bash
./send-messages-to-n-subjects.sh
```

## Experiment 2 - stream benchark

Check performance of a stream with given configuration.
Run multiple times in order to check streams with different configurations.

Script usage:
```bash
./stream-pub-bench.sh --stream STREAM_NAME --msgs NUMBER_OF_MSGS_TO_PUBLISH
```

Note: restart NATS cluster between runs for results comparability:
```bash
docker compose -f docker-compose.yml restart
```