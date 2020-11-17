# Tweet UI

Sentiment analysis UI to check whether tweets are ok or not.

## Format

The UI will query the backend API using a POST to `$BASE_URL/api/analysis` containing the following json body:

```json
{
    "content": "This is a bad sentence"
}
```

It expects a response in the format:

```json
{
    "toxicity":false,
    "threat":false,
    "sexualExplicit":false,
    "severeToxicity":false,
    "obscene":false,
    "insult":false,
    "identityAttack":false
}
```

<span style='color: red'>
The `$BASE_URL` environment variable should be set at build time.
</span>

## Usage

You can run the service locally by running:

```sh
npm install
BASE_URL=http://localhost:8080 npm run webpack:server
```

## Deployment

You can deploy the UI as a static website or as a service, it's up to you.

### Static website

To bundle the UI for static website deployment, run

```sh
npm install
BASE_URL=http://localhost:8080 npm run webpack:bundle
```

This will bundle the HTML and js files into the `dist/` folder which you can then deploy.
To test that the site works, run

```sh
npm run serve
```

and open `http://localhost:9000`

### Service

To deploy the UI as a service, you can use the provided [Dockerfile](./docker/Dockerfile) which runs the UI in an integrated HTTP server, e.g. by running:

```sh
docker build --build-arg base_url=http://localhost:8080 -t="hivemind/tweet-ui" -f docker/Dockerfile .
docker run -ti -p 9000:9000 hivemind/tweet-ui:latest
```

and open `http://localhost:9000`
