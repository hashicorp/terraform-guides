# Provision a Cloud SQL instance for PostgreSQL on Google Cloud Platform.

[Cloud SQL for PostgreSQL(https://cloud.google.com/sql/docs/postgres/) is a fully-managed PostgreSQL relational database service on Google Cloud Platform. This Terraform configuration will create a Cloud SQL PostgreSQL V9.6 instance in Google Cloud. It can also be used as a Module to instantiate one or more instances quickly.

### Pre-requisites:
- A [Google Cloud](https://cloud.google.com/) account and [project](https://cloud.google.com/docs/overview/#projects).
- `Google Cloud SQL` and `Cloud SQL Admin API` APIs must be enabled on the project. This can be enabled on [Google cloud console](https://support.google.com/cloud/answer/6158841?hl=en) or CLI.
- Google Cloud credentials `.json` file from a Service Account is required. This can be obtained by generating a [Service Account Key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).
- Terraform installed on a machine where this configuration will be downloaded and run: [Terraform install instructions](https://www.terraform.io/intro/getting-started/install.html)

### Module Examples:
- [Simple](examples/simple/README.md): Provisions an example Cloud SQL instance.
- [Prod and Dev](examples/prod-and-dev/README.md): Provisions example Prod and Dev CloudSQL instances.

### Usage:

**Download and configure provider:**
- Clone this repository via `git` or HTTP and change to working directory: `cd terraform-gcp-cloudsql`.
- Set the following environment variables appropriately to setup the [Terraform Google Provider](https://www.terraform.io/docs/providers/google/index.html).
```
export GOOGLE_CLOUD_KEYFILE_JSON=<path-to-service-account-keyfile>
export GOOGLE_PROJECT=<name-of-project>
```

**Set Configuration variables:**
- Set the following [Terraform Configuration variables](https://www.terraform.io/docs/configuration/variables.html) specified as environment variables with `TF_VAR` prefix.
```
export TF_VAR_gcp_sql_root_user_pw=<pw>
export TF_VAR_authorized_network="$(curl whatismyip.akamai.com)/32"
```
- Note: the `authorized_network` variable above should be set to the system you will access PostgreSQL from. In this we are assuming Terraform will run from the same machine that PostgreSQL will be accessed from. This assumption will not hold true in case of Terraform Enterprise or a separate Terraform build server.
- Adjust any other Terraform configuration variables in [variables.tf](variables.tf).

**Run terraform:**
- Run the terraform commands below to initialize the configuration:
```
terraform init
terraform plan
```
- If everything looks good, go ahead with apply: `terraform apply`.
- To view outputs issue: `terraform output`.

**(Optional) Connect to PostgreSQL instance**:
- To connect to PostgreSQL using the `psql` CLI, please install it on your system (if not already available).
- Make a note of the IP address from terraform output: `terraform output`. If you have `jq` installed, you can export it to a variable: `export sql_ip=$(terraform output -json | jq -r .ip.value)`
- Adjust the `hostaddr` parameter to connect using `psql`:
```
psql "sslmode=disable dbname=postgres user=root hostaddr=${sql_ip}"
```
- (Optional): run some sql statements from the `psql` prompt:
```
CREATE TABLE cities (
	name            varchar(80),
	location        char(2)
	);
INSERT INTO cities VALUES ('San Francisco', 'CA');
INSERT INTO cities VALUES ('Buffalo', 'NY');
SELECT * from cities;
\q
```

**Cleanup:**
- To destroy the Cloud SQL instance, issue: `terraform destroy`.
- Unset environment variables:
```
unset GOOGLE_CLOUD_KEYFILE_JSON
unset GOOGLE_PROJECT
unset TF_VAR_gcp_sql_root_user_pw
unset GOOGLE_PROJECT
```
