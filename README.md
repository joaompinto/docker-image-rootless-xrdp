# docker-image-rootless-xrdp
Docker image providing a rootless xrdp environment

## Build
```sh
docker build -t rootless-xrdp "."
```

## Test
```sh
docker run -p13389:3389 rootless-xrdp
```

On Windows:

    Windows key + R: mstsc /v localhost:13389
    User: developer
    Password: «leave it empty»

You should get a xterm