# capstan-bootstrap

Get started faster with [Kenzan Capstan](https://github.com/kenzanlabs/capstan).

Provides a docker container that automates setup steps described in the Getting Started READMEs.

## Support

* Currently automates steps for GCP ([see here](https://github.com/kenzanlabs/capstan/tree/master/gcp)).

## Requirements

* Run Docker 18.06.1 or later
* Google Cloud Platform account with admin access (i.e setting up a trial account is a good option)

## Get Started

For GCP, setup a project, service account and credentials...

* Choose a name for the GCP project (i.e. capstandemoNN is a placeholder and default; replace NN with your value)
* Create a GCP project (based on choosen name)
* Create a GCP terraform-admin service account ([see here](https://github.com/kenzanlabs/capstan/tree/master/gcp)) 
* Download your service account JSON file

Reference

* https://github.com/kenzanlabs/capstan/tree/master/gcp

Review the environment variable default values.

```
$ make debug
CONTAINER_NAME       = kenzan/capstan
CONTAINER_VERSION    = 0.0.x
CONTAINER_ROOT       = .container.root
GIT_AUTHOR_NAME      = Firstname Lastname
GIT_AUTHOR_EMAIL     = username@domain.tld
CAPSTAN_REPO         = https://github.com/kenzanlabs/capstan.git
CAPSTAN_TAG          = master
GCP_ACCOUNT          = your.capstan.demo.account@gmail.com
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
