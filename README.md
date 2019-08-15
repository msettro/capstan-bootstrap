# capstan-bootstrap

Get started faster with [Kenzan Capstan](https://github.com/kenzanlabs/capstan).

Provides a docker container that automates setup steps described in the Getting Started READMEs.

## Limitations

* Currently automates setup steps for Capstan for GCP ([see here](https://github.com/kenzanlabs/capstan/tree/master/gcp)).

## Requirements

* Run Docker 18.06.1 or later
* Google Cloud Platform account with admin access (i.e setting up a trial account is recommended)

## Get Started

1. Review the environment defaults

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

2. Edit the Makefile

Set GCP_ACCOUNT to the value of the Gmail account associated to your GCP account

```
$ vi Makefile
```

3. Build the bootstrap container and container root:

```
$ make container
$ make container.root
```

4. Go inside the container

```
$ make shell
```

5. While inside the container...

...start the bootstrap process...

```
bash-4.4# make cdenv
```

... and finish the bootstrap proces...

```
bash-4.4# make hal.deploy.connect
bash-4.4# make is.hal.connected
bash-4.4# make spin.app
bash-4.4# make external.tunnel.command

```

7. Access Spinnaker

Outside the container...

```
$ make external.tunnel
```

In a browser, goto http://localhost:9000
