# Docker from Conda

This repository contains a (mostly) minimal example of how to build a docker image from an existing conda `environment.yml` file. The example file is intended for development purposes only (fast prototyping), and is not recommended for production. Primarily designed for our internal infrastructure at UC San Diego, but may be useful more broadly.

## Instructions

1. Place `Dockerfile` in the same directory as your `environment.yml` file
2. Build the image with: `docker build . -t <name:tag>`

That's all!

## Contributing

Feel free to open a PR if you have any suggestions for how to improve the `Dockerfile` or documentation.
