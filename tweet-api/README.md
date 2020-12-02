# tweet API

HTTP backend for `tweet-ui`.

## Hints

If the UI and API will run on different endpoints, you need to set HTTP headers accordingly, e.g.:

```http
Access-Control-Allow-Origin: *
```

sbt clean assembly

docker build -t "hivemind/tweet-api" -f docker/Dockerfile .

docker run -ti -p 8080:8080 -e SERVICE_URL=http://localhost:9090 HOST=0.0.0.0 -e PORT=8080 hivemind/tweet-api:latest