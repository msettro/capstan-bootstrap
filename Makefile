#
# file: Makefile
# description: Use these targets to create a bootstrap container 
#              that makes it easy to run kenzan/capstan.
#
# usage:
#
#    $ make container
#    $ make .container.root
#    $ cp ~/Downloads/capstandemoNN*.json .container.root/
#    $ make shell
#    bash-4.4# make init
#    bash-4.4# make terraform
#
# debugging usage:
#
#    $ make < clean | superclean >
#

CONTAINER_NAME      ?= kenzan/capstan
CONTAINER_VERSION   ?= $(shell cat VERSION)

GIT_AUTHOR_NAME     ?= Firstname Lastname
GIT_AUTHOR_EMAIL    ?= username@domain.tld

CAPSTAN_REPO        ?= https://github.com/kenzanlabs/capstan.git
CAPSTAN_TAG         ?= master

GCP_PROJECT         ?= capstandemoNN
GCP_ZONE            ?= us-central1-a
GCP_SERVICE_ACCOUNT ?= terraform-admin

CONTAINER_ROOT = .container.root

###

.PHONY: nothing debug superclean clean shell clean.$(CONTAINER_ROOT) kenzan/capstan container clean.container

nothing:

debug:
	@printf "%-20.20s = %s\n" CONTAINER_NAME      "$(CONTAINER_NAME)"
	@printf "%-20.20s = %s\n" CONTAINER_VERSION   "$(CONTAINER_VERSION)"
	@printf "%-20.20s = %s\n" CONTAINER_ROOT      "$(CONTAINER_ROOT)"

	@printf "%-20.20s = %s\n" GIT_AUTHOR_NAME     "$(GIT_AUTHOR_NAME)"
	@printf "%-20.20s = %s\n" GIT_AUTHOR_EMAIL    "$(GIT_AUTHOR_EMAIL)"

	@printf "%-20.20s = %s\n" CAPSTAN_REPO        "$(CAPSTAN_REPO)"
	@printf "%-20.20s = %s\n" CAPSTAN_TAG         "$(CAPSTAN_TAG)"

	@printf "%-20.20s = %s\n" GCP_PROJECT         "$(GCP_PROJECT)"
	@printf "%-20.20s = %s\n" GCP_ZONE            "$(GCP_ZONE)"
	@printf "%-20.20s = %s\n" GCP_SERVICE_ACCOUNT "$(GCP_SERVICE_ACCOUNT)"

superclean: clean.container clean.container.root

clean: clean.container

###

shell: $(CONTAINER_ROOT)
	docker run -it \
	   -v $$(pwd)/$(CONTAINER_ROOT):/root        \
	   -e CAPSTAN_REPO="$(CAPSTAN_REPO)"         \
	   -e CAPSTAN_TAG="$(CAPSTAN_TAG)"           \
	   -e GCP_PROJECT="$(GCP_PROJECT)"           \
	   -e GCP_ZONE="$(GCP_ZONE)"                 \
	   -e GCP_SERVICE_ACCOUNT="$(GCP_SERVICE_ACCOUNT)" \
	   -e GIT_AUTHOR_NAME="$(GIT_AUTHOR_NAME)"   \
	   -e GIT_AUTHOR_EMAIL="$(GIT_AUTHOR_EMAIL)" \
	   -e TF_VAR_gcp_project_id=$(GCP_PROJECT)   \
	   -e TF_VAR_ssh_user=$(GCP_PROJECT)         \
	   $(CONTAINER_NAME):$(CONTAINER_VERSION) /bin/bash

container.root: $(CONTAINER_ROOT)

$(CONTAINER_ROOT):
	mkdir $(@)
	cp -R tmpl/root/* $(@)/

clean.container.root:
	if [[ -d $(CONTAINER_ROOT) ]]; then rm -Rf $(CONTAINER_ROOT); else :; fi

###

$(CONTAINER_NAME): container

container: 
	docker build -t $(CONTAINER_NAME):$(CONTAINER_VERSION) -t $(CONTAINER_NAME):latest -f Dockerfile .
	docker images | grep $(CONTAINER_NAME)

clean.container:
	docker image rm --force $(CONTAINER_NAME):$(CONTAINER_VERSION) $(CONTAINER_NAME):latest 

