# tweet API

HTTP backend for `tweet-ui`.

## Hints

If the UI and API will run on different endpoints, you need to set HTTP headers accordingly, e.g.:

```http
Access-Control-Allow-Origin: *
```

docker build -t "hivemind/tweet-api" -f docker/Dockerfile .

docker run -ti -p 8080:8080 -e HOST=0.0.0.0 -e PORT=8080 hivemind/tweet-api:latest