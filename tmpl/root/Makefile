#
# usage:
#   make < init | debug | clean >
#

GCP_ZONE=$(shell cat .config/gcloud/configurations/config_default | grep zone | awk '{ printf("%s",$$3) }')

nothing:

init: .gitconfig capstan gcloud gcloud.services gcloud.test gcp-account.json

clean: clean.gitconfig clean.capstan clean.gcloud clean.gcloud.test clean.gcp-account.json clean.terraform

debug:
	@printf "%-20.20s = %s\n" "CAPSTAN_REPO"           "$(CAPSTAN_REPO)"
	@printf "%-20.20s = %s\n" "CAPSTAN_TAG"            "$(CAPSTAN_TAG)"

	@printf "%-20.20s = %s\n" "GCP_PROJECT"            "$(GCP_PROJECT)"
	@printf "%-20.20s = %s\n" "GCP_ZONE"               "$(GCP_ZONE)"
	@printf "%-20.20s = %s\n" "GCP_SERVICE_ACCOUNT"    "$(GCP_SERVICE_ACCOUNT)"

	@printf "%-20.20s = %s\n" "GIT_AUTHOR_EMAIL"       "$(GIT_AUTHOR_EMAIL)"
	@printf "%-20.20s = %s\n" "GIT_AUTHOR_NAME"        "$(GIT_AUTHOR_NAME)"

	@printf "%-20.20s = %s\n" "TF_VAR_gcp_project_id"  "$(TF_VAR_gcp_project_id)"
	@printf "%-20.20s = %s\n" "TF_VAR_ssh_user"        "$(TF_VAR_ssh_user)"

###

spinnaker: terraform

terraform:
	cd /root/capstan/gcp/terraform/ \
	   && terraform init  -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) \
	   && terraform plan  -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) \
	   && terraform apply -var gcp_project_id=$(GCP_PROJECT) -var ssh_user=$(GCP_PROJECT) -auto-approve -refresh=true | tee -a /root/terraform.log

clean.terraform:
	rm -Rf /root/.terraform.d /root/capstan/gcp/terraform/.terraform.d

###

gcp-account.json: /root/capstan/gcp/terraform/gcp-account.json

/root/capstan/gcp/terraform/gcp-account.json:
	cp /root/capstan*json /root/capstan/gcp/terraform/gcp-account.json

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
