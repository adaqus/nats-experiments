# NATS JetStream experiments

Starting the cluster:

```bash
docker compose -f docker-compose.yml up -d
```

## Experiment 1 - number of subjects

Check limits of number of subjects in single stream.

Test script:
```bash
time ./send-messages-to-n-subjects.sh
```

