FROM gcr.io/google.com/cloudsdktool/cloud-sdk as base
WORKDIR /root/aiinfra
RUN apt-get update \
    && apt-get --quiet install -y bash bc curl git jq python3-pip zip \
    && apt-get --quiet clean autoclean \
    && apt-get --quiet autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && mkdir -p /root/.local/bin
ENV PATH="${PATH}:/usr/local/gcloud/google-cloud-sdk/bin:/root/.local/bin"
ENV SLURM_VERSION="5.7.2"
RUN python3 -m pip install -r "https://raw.githubusercontent.com/SchedMD/slurm-gcp/${SLURM_VERSION}/scripts/requirements.txt"
ENV TERRAFORM_VERSION="1.4.6"
RUN curl -s "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o ./terraform.zip \
    && unzip -uq ./terraform.zip \
    && rm -f ./terraform.zip \
    && mv ./terraform /root/.local/bin/terraform
COPY ./a3/terraform ./a3/terraform
COPY ./a2/terraform ./a2/terraform
COPY ./a3-mega/terraform ./a3-mega/terraform

FROM base as test
COPY test ./test
COPY scripts ./scripts


FROM test as test-pr
ENTRYPOINT ["./test/pr/run.sh"]


FROM test as test-continuous
ENTRYPOINT ["./test/continuous/run.sh"]


FROM base as deploy
RUN for cluster in gke mig mig-cos; do \
    terraform -chdir="./a3-mega/terraform/modules/cluster/${cluster}" init; done
RUN for cluster in gke gke-beta mig mig-cos slurm; do \
    terraform -chdir="./a3/terraform/modules/cluster/${cluster}" init; done
RUN for cluster in mig; do \
    terraform -chdir="./a2/terraform/modules/cluster/${cluster}" init; done
COPY scripts ./scripts
ENTRYPOINT ["./scripts/entrypoint.sh"]
