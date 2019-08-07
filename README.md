# capstan-bootstrap

Get started with capstan by running this docker container.

## Requirements

* Choose a name for your project (i.e. capstandemoNN is used default, replace with your value)
* Create a GCP account (optional)
* Create a GCP project (based on choosen name)
* Docker 18.06.1 or later

## Get Started

Review the environment variable default values.

```
$ make debug
CONTAINER_NAME       = kenzan/capstan
CONTAINER_VERSION    = 0.0.1
CONTAINER_ROOT       = .container.root
GIT_AUTHOR_NAME      = Firstname Lastname
GIT_AUTHOR_EMAIL     = username@domain.tld
CAPSTAN_REPO         = https://github.com/kenzanlabs/capstan.git
CAPSTAN_TAG          = master
GCP_PROJECT          = capstandemoNN
GCP_ZONE             = us-central1-a
GCP_SERVICE_ACCOUNT  = terraform-admin
```

Choose to update the environment values by exporting the new values, setting them on the make command line, or to new values by exporting

```
$ export CAPSTAN_REPO=https://github.com/myrepo/capstan.git
$ export CAPSTAN_TAG=feature/mynewfeature
```

Build the bootstrap container:

```
$ make container
$ make .container.root
```

Copy the service account JSON downloaded while setting up GCP project into .container.root

```
$ cp ~/Downloads/capstandemoNN*.json .container.root/
```

Next, inside the container, initialize and run Capstan with your GCP project and credentials

```
$ make shell
bash-4.4# make init
bash-4.4# make terraform
```
