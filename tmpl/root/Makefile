#
# usage:
#   make < cdenv | hal.deploy.connect | is.hal.connected | external.tunnel.command | debug | clean >
#

GCP_ZONE ?= $(shell [[ -f .config/gcloud/configurations/config_default ]] && cat .config/gcloud/configurations/config_default | grep zone | awk '{ printf("%s",$$3) }')
GCP_PROJECT = $(shell cat gcp.project.name)

nothing:

#
# note on the finish target
#
#    `make target` doesn't work well w/o manual intervention because hal.deploy.connect
#    hangs up the terminal and requires Ctrl^C which stops the execution of the
#    subsequent make targets.
#
#    the work around...
#      run each of the finish dependencies individually
#
finish: hal.deploy.connect is.hal.connected spin.setup external.tunnel.command

cdenv: .gitconfig capstan gcloud gcloud.test terraform

clean: clean.external.tunnel.command clean.spinnaker.app clean.terraform clean.gcp-account.json clean.gcloud.test clean.gcloud clean.capstan clean.gitconfig

debug:
	@printf "%-25.25s = %s\n" "CAPSTAN_REPO"           "$(CAPSTAN_REPO)"
	@printf "%-25.25s = %s\n" "CAPSTAN_TAG"            "$(CAPSTAN_TAG)"

	@printf "%-25.25s = %s\n" "GCP_ACCOUNT"            "$(GCP_ACCOUNT)"

	@printf "%-25.25s = %s\n" "GCP_PROJECT"            "$(GCP_PROJECT)"

	@printf "%-25.25s = %s\n" "GCP_ZONE"               "$(GCP_ZONE)"
	@printf "%-25.25s = %s\n" "GCP_SERVICE_ACCOUNT"    "$(GCP_SERVICE_ACCOUNT)"

	@printf "%-25.25s = %s\n" "GIT_AUTHOR_EMAIL"       "$(GIT_AUTHOR_EMAIL)"
	@printf "%-25.25s = %s\n" "GIT_AUTHOR_NAME"        "$(GIT_AUTHOR_NAME)"

###

external.tunnel.command:
	@echo ssh -i .container.root/.ssh/google_compute_engine \
	          -o \'StrictHostKeyChecking no\' -o \'UserKnownHostsFile /dev/null\' \
	          -L 9000:localhost:9000 -L 8084:localhost:8084 \
		      $(GCP_PROJECT)@$$(gcloud compute instances list | grep halyard-tunnel | awk '{ printf("%s", $$5) }') >  external.tunnel.command
	@#
	@# Note: this ssh command should run in separate shell outside of capstan-bootstrap container
	@#
	@#echo
	@#echo ###############################
	@#echo ... you\'re almost there...
	@#echo run this script from your workstation in a
	@#echo terminal session outside of this capstan-bootstrap container
	@#echo ###############################
	@#echo
	@#echo created external.tunnel.command
	@#ls -l external.tunnel.command

clean.external.tunnel.command:
	rm -Rf external.tunnel.command

###

spin.setup: spin.app spin.initial.pipeline

spin.initial.pipeline: spinnaker.initial.pipeline

spinnaker.initial.pipeline:
	@CMD_LINES=5 CMD='cd pipelines/gcp/0-initial/ && spin pipeline save --file=uat_deploy.json && spin pipeline save --file=prod_seed.json && kubectl apply -f prod-loadbalancer.yaml && kubectl apply -f uat-loadbalancer.yaml && kubectl apply -f dev-loadbalancer.yaml' \
		$(MAKE) --no-print-directory halyard.tunnel.command

spin.app: spinnaker.app

spinnaker.app:
	@CMD_LINES=5 CMD='echo "{ \"cloudProviders\": \"kubernetes\", \"email\": \"$(GCP_ACCOUNT)\", \"name\": \"helloagain\" }" | spin application save' \
		$(MAKE) --no-print-directory halyard.tunnel.command

clean.spin.app: clean.spinnaker.app

clean.spinnaker.app:
	@#
	@# yikes! just so you know...
	@#    spin application delete can throw a SIGSEGV fault
	@#       panic: runtime error: invalid memory address or nil pointer dereference
	@#       [signal SIGSEGV: segmentation violation code=0x1 addr=0x10 pc=0x8685f3]
	@#
	@#    if it does, you may need to start over... (sorry)
	@#
	@CMD_LINES=5 CMD='(spin application delete helloagain) || :;' $(MAKE) --no-print-directory halyard.tunnel.command

###

spin.app.list: spin.application.list

spin.application.list:
	@CMD_LINES=5 CMD='spin application list' \
		$(MAKE) --no-print-directory halyard.tunnel.command

spin.cli.help: spinnaker.cli.help

spinnaker.cli.help:
	@CMD_LINES=1 CMD='spin --help' \
		$(MAKE) --no-print-directory halyard.tunnel.command

spin.cli.version: spinnaker.cli.version

spinnaker.cli.version:
	@CMD_LINES=1 CMD='spin --version' \
		$(MAKE) --no-print-directory halyard.tunnel.command

###

is.hal.connected:
	@CMD_LINES=3 CMD='lsof -nP -i4TCP:8084 -i4TCP:9000' \
		$(MAKE) --no-print-directory halyard.tunnel.command

hal.deploy.connect:
	@echo
	@echo
	@echo please wait for \'Connect to Spinnaker deployment, Successful\' messages
	@echo     you may need to use ^C to exit
	@echo     follow up with a \'make is.hal.connected\'
	@echo
	@echo
	@CMD_LINES=10 CMD='nohup hal deploy connect &' \
		$(MAKE) --no-print-directory halyard.tunnel.command

	$(MAKE) is.hal.connected

clean.hal.deploy.connect:
	@#
	@# !! todo avoid this error (which can be ignored) !!
	@#
	@CMD_LINES=0 CMD='(kill -9 \
	   `lsof -nP -i4TCP:8084 | grep LISTEN | cut -d\  -f2` \
	   `lsof -nP -i4TCP:9000 | grep LISTEN | cut -d\  -f2` \
	   `ps -ef | grep "hal deploy connect" | grep /usr/local/bin/hal | cut -d\  -f2 2>&1` \
	   && rm -Rf .hal.output) || :;' \
	        $(MAKE) --no-print-directory halyard.tunnel.command

###

cmd.hal: halyard.tunnel.command

hal.cmd: halyard.tunnel.command

halyard.tunnel.command:
	gcloud compute --project "$(GCP_PROJECT)" \
	   ssh --zone "us-central1-f" --ssh-flag="-o ConnectTimeout=3" \
	      "$(GCP_PROJECT)@halyard-tunnel" --command='$(CMD)'

###

sh.hal:    halyard.tunnel.shell

hal.sh:    halyard.tunnel.shell

shell.hal: halyard.tunnel.shell

hal.shell: halyard.tunnel.shell

halyard.tunnel.shell:
	gcloud compute --project "$(GCP_PROJECT)" ssh --zone "us-central1-f" "$(GCP_PROJECT)@halyard-tunnel" $(CMD)

###

terraform.show:
	cd /root/capstan/gcp/terraform/ \
	   && time terraform show

terraform: capstan gcp-account.json
	cd /root/capstan/gcp/terraform/ \
	   && time terraform init  -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) \
	   && time terraform plan  -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) \
	   && time terraform apply -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) -auto-approve -refresh=true | tee -a /root/terraform.log

clean.terraform:
	cd /root/capstan/gcp/terraform/ \
	   && time terraform destroy -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT)
	rm -Rf /root/.terraform.d /root/capstan/gcp/terraform/.terraform.d terraform.log

###

gcp-account.json: /root/capstan/gcp/terraform/gcp-account.json

/root/capstan/gcp/terraform/gcp-account.json:
	cp /root/$(GCP_PROJECT)*json /root/capstan/gcp/terraform/gcp-account.json

clean.gcp-account.json:
	rm -Rf /root/capstan/gcp/terraform/gcp-account.json


###

gcloud.test: gcloud.test.setup gcloud.test.ssh

gcloud.test.ssh:
	echo 'uname -a' | gcloud compute --project "$(GCP_PROJECT)" ssh --zone "$(GCP_ZONE)" "$(GCP_PROJECT)@$$(cat test-instance-name)"

gcloud.test.setup: test-instance-name
	gcloud compute instances create "$$(cat test-instance-name)" \
	   --project "$(GCP_PROJECT)" \
	   --zone "$(GCP_ZONE)" \
	   --service-account=$(GCP_SERVICE_ACCOUNT)@$(GCP_PROJECT).iam.gserviceaccount.com
	sleep 4

test-instance-name:
	if [[ ! -f test-instance-name ]]; then echo "test-instance-$(shell shuf -i10-100 -n1)" > test-instance-name; fi

clean.gcloud.test:
	( [[ -f test-instance-name ]] && (gcloud compute instances list --filter="name=('$$(cat test-instance-name)')" ) || :; )
	( [[ -f test-instance-name ]] && (gcloud compute instances delete "$$(cat test-instance-name)" ) || :; )
	( [[ -f test-instance-name ]] && rm -Rf test-instance-name ) || :;
	rm -Rf .ssh

###

gcloud: gcp.project.name gcloud.auth gcp.project gcloud.services gcloud.service.account gcloud.service.account.role gcloud.service.account.key gcloud.info

clean.gcloud: clean.gcloud.service.account.key clean.gcp.project clean.gcloud.auth clean.gcp.project.name

gcloud.info:
	gcloud info

gcloud.service.account.key:
	gcloud iam service-accounts keys create $(GCP_PROJECT).json --iam-account $(GCP_SERVICE_ACCOUNT)@$(GCP_PROJECT).iam.gserviceaccount.com

clean.gcloud.service.account.key:
	rm -Rf $(GCP_PROJECT).json

gcloud.service.account.role:
	gcloud projects add-iam-policy-binding $(GCP_PROJECT) \
	  --member serviceAccount:$(GCP_SERVICE_ACCOUNT)@$(GCP_PROJECT).iam.gserviceaccount.com \
	  --role roles/iam.serviceAccountUser
	gcloud projects add-iam-policy-binding $(GCP_PROJECT) \
	  --member serviceAccount:$(GCP_SERVICE_ACCOUNT)@$(GCP_PROJECT).iam.gserviceaccount.com \
	  --role roles/owner

gcloud.service.account: gcloud.component.install
	gcloud beta iam service-accounts create "$(GCP_SERVICE_ACCOUNT)" \
	   --description "Enables Capstan to provision the Spinnaker environment." \
	   --display-name "$(GCP_SERVICE_ACCOUNT)"

gcloud.component.install:
	echo y | time gcloud components install beta

gcloud.services: gcloud.billing.account.confirm
	time gcloud services enable cloudresourcemanager.googleapis.com
	time gcloud services enable container.googleapis.com
	time gcloud services enable iam.googleapis.com

gcloud.billing.account.confirm:
	@echo
	@echo .......................
	@echo
	@echo please set a billing account...
	@echo 1. goto https://console.developers.google.com/project/$(GCP_PROJECT)/settings
	@echo 2. click the "Link a billing account" button and follow the dialogs
	@printf "3. ready to continue? [hit enter]: " && read continue
	@echo
	@echo .......................

gcp.project:
	time gcloud projects create $(GCP_PROJECT)
	time gcloud config set project $(GCP_PROJECT)
	time gcloud config set billing/quota_project $(GCP_PROJECT)

clean.gcp.project:
	time gcloud projects delete $(GCP_PROJECT) || :;

gcloud.auth:
	time gcloud auth login "$(GCP_ACCOUNT)"

clean.gcloud.auth:
	rm -Rf .boto .config

gcp.project.name:
	if [[ ! -f gcp.project.name ]]; then echo "capstandemo$(shell shuf -i1000-9999 -n1)" > gcp.project.name; fi

clean.gcp.project.name:
	rm -Rf gcp.project.name

###

capstan:
	git clone $(CAPSTAN_REPO) \
	   && cd capstan \
	   && git checkout $(CAPSTAN_TAG) \
	   && git log -1

clean.capstan:
	rm -Rf capstan

###

.gitconfig:
	printf "[user]\n\tname = $(GIT_AUTHOR_NAME)\n\temail = $(GIT_AUTHOR_EMAIL)\n" > .gitconfig

clean.gitconfig:
	rm -Rf .gitconfig
