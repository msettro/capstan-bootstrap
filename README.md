# capstan-bootstrap

Get started with capstan by running this docker container.

## Requirements

* Choose a name for your project (i.e. capstandemoNN is used default, replace with your value)
* Docker 18.06.1 or later

### Get Started

```
$ make container
$ make .container.root
$ cp ~/Downloads/capstandemoNN*.json .container.root/
$ make shell
```
Then inside the container...

```
bash-4.4# make init
bash-4.4# make spinnaker
```

### Environment Variables

Use `make debug` The following environment variable cusomtize values defaulted in the Makefile and used in the capstan-bootsrap container

```
CONTAINER_NAME="..."        \
CONTAINER_VERSION="..."     \
GIT_AUTHOR_NAME="..."       \
GIT_AUTHOR_EMAIL="..."      \
CAPSTAN_REPO="https://github.com/myaccount/capstan.git"\
CAPSTAN_TAG="< branch_name | tag_name | commit hash >" \
GCP_PROJECT="capstandemoNN" \
GCP_ZONE="..."              \
GCP_SERVICE_ACCOUNT="..."   \
   make container
```
