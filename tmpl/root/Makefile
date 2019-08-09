#
# usage:
#   make < init | spinnaker | debug | clean >
#

GCP_ZONE ?= $(shell [[ -f .config/gcloud/configurations/config_default ]] && cat .config/gcloud/configurations/config_default | grep zone | awk '{ printf("%s",$$3) }')

nothing:

external.tunnel.command:
	# Note: run this ssh command (or an equivalent) from outside of capstan-bootstrap container
	@echo ssh -i .container.root/.ssh/google_compute_engine -L 9000:localhost:9000 -L 8084:localhost:8084 \
		$(GCP_PROJECT)@$$(gcloud compute instances list | grep halyard-tunnel | awk '{ printf("%s", $$5) }')

cdenv: terraform hal.deploy.connect

init: .gitconfig capstan gcloud gcloud.services gcloud.test gcp-account.json

clean: clean.terraform clean.gcp-account.json clean.gcloud.test clean.gcloud clean.capstan clean.gitconfig

debug:
	@printf "%-25.25s = %s\n" "CAPSTAN_REPO"           "$(CAPSTAN_REPO)"
	@printf "%-25.25s = %s\n" "CAPSTAN_TAG"            "$(CAPSTAN_TAG)"

	@printf "%-25.25s = %s\n" "GCP_PROJECT"            "$(GCP_PROJECT)"
	@printf "%-25.25s = %s\n" "GCP_ZONE"               "$(GCP_ZONE)"
	@printf "%-25.25s = %s\n" "GCP_SERVICE_ACCOUNT"    "$(GCP_SERVICE_ACCOUNT)"

	@printf "%-25.25s = %s\n" "GIT_AUTHOR_EMAIL"       "$(GIT_AUTHOR_EMAIL)"
	@printf "%-25.25s = %s\n" "GIT_AUTHOR_NAME"        "$(GIT_AUTHOR_NAME)"

	@printf "%-25.25s = %s\n" "TF_VAR_gcp_project_id"  "$(TF_VAR_gcp_project_id)"
	@printf "%-25.25s = %s\n" "TF_VAR_ssh_user"        "$(TF_VAR_ssh_user)"

###

is.hal.connected:
	@CMD_LINES=3 CMD='lsof -nP -i4TCP:8084 -i4TCP:9000' \
		$(MAKE) --no-print-directory halyard.tunnel.command

hal.deploy.connect:
	# please ^C to exit, then do a `make is.hal.connected`
	@CMD_LINES=10 CMD='nohup hal deploy connect &' \
		$(MAKE) --no-print-directory halyard.tunnel.command

clean.hal.deploy.connect:
	@CMD_LINES=0 CMD='kill -9 \
	   `lsof -nP -i4TCP:8084 | grep LISTEN | cut -d\  -f2` \
	   `lsof -nP -i4TCP:9000 | grep LISTEN | cut -d\  -f2` \
	   `ps -ef | grep "hal deploy connect" | grep /usr/local/bin/hal | cut -d\  -f2 2>&1` \
	   && rm .hal.output' \
	        $(MAKE) --no-print-directory halyard.tunnel.command

###

cmd.hal: halyard.tunnel.command

hal.cmd: halyard.tunnel.command

halyard.tunnel.command:
	@echo '$(CMD)' | gcloud compute --project "$(GCP_PROJECT)" ssh --zone "us-central1-f" "$(GCP_PROJECT)@halyard-tunnel" --ssh-flag="-o ConnectTimeout=3" 2>&1 | tail -$(CMD_LINES)

###

shell.hal: halyard.tunnel.shell

hal.shell: halyard.tunnel.shell

halyard.tunnel.shell:
	gcloud compute --project "$(GCP_PROJECT)" ssh --zone "us-central1-f" "$(GCP_PROJECT)@halyard-tunnel"


###

terraform.destroy:
	cd /root/capstan/gcp/terraform/ \
	   && time terraform destroy -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT)

terraform.show:
	cd /root/capstan/gcp/terraform/ \
	   && time terraform show

terraform: capstan gcp-account.json
	cd /root/capstan/gcp/terraform/ \
	   && time terraform init  -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) \
	   && time terraform plan  -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) \
	   && time terraform apply -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) -auto-approve -refresh=true | tee -a /root/terraform.log

clean.terraform:
	rm -Rf /root/.terraform.d /root/capstan/gcp/terraform/.terraform.d

###

gcp-account.json: /root/capstan/gcp/terraform/gcp-account.json

/root/capstan/gcp/terraform/gcp-account.json:
	cp /root/$(GCP_PROJECT)*json /root/capstan/gcp/terraform/gcp-account.json

clean.gcp-account.json:
	rm -Rf /root/capstan/gcp/terraform/gcp-account.json

###

gcloud.info:
	gcloud info

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

gcloud.services:
	time gcloud services enable cloudresourcemanager.googleapis.com
	time gcloud services enable container.googleapis.com
	time gcloud services enable iam.googleapis.com

gcloud:
	time gcloud --project=$(GCP_PROJECT) init

clean.gcloud:
	rm -Rf .boto .config

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
