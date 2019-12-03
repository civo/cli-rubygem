# Civo CLI in Docker

Build a docker container embedded with the latest civo command.  Note that it does NOT yet build from source;
it simply pulls the latest civo cli from RubyGems.  Usage is in the main repo's README.  The docker that builds
from source is a work in progress and available at https://github.com/ssmiller25/cli/tree/dockerbuild

##


## Pushing to Civo's official DockerHub

From the repository build it with the current version and "latest" tags:

```
docker build -t civo/cli:latest -f docker/Dockerfile .
docker build -t civo/cli:0.x.y -f docker/Dockerfile .
```

Then after running `docker login` to authenticate to the Civo organisation you can do:

```
docker push civo/cli:latest
docker push civo/cli:0.x.y
```