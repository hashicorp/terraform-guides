## Provision PostgreSQL Google Cloud SQL instance using modules.

This Terraform Configuration provisions 2 Google Cloud SQL PostgreSQL instances on Google Cloud using the  `terraform-gcp-cloudsql` module. The example modules are named as `prod-gcp-cloudsql` and `dev-gcp-cloudsql`.

**Download and configure provider:**
- Clone this repository via `git` or HTTP and change to working directory: `cd terraform-gcp-cloudsql/examples/prod-and-dev`.
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
- Note: if you made any changes to the module, obtain the latest version using: `terraform get -update=true`.
- If everything looks good, go ahead with apply: `terraform apply`.
- To view module outputs issue the following commands:
```
terraform output -module=prod-gcp-cloudsql
terraform output -module=dev-gcp-cloudsql
```


**(Optional) Connect to PostgreSQL instance**:
- To connect to PostgreSQL using the `psql` CLI, please install it on your system (if not already available).
- Make a note of the IP addresses from terraform output commands above.
  - If you have `jq` installed, you can export these addresses to variables:
  - For the `prod-gcp-cloudsql`, issue: `export prod_sql_ip=$(terraform output -module=prod-gcp-cloudsql -json | jq -r .ip.value)`
  - For the `dev-gcp-cloudsql`, issue: `export dev_sql_ip=$(terraform output -module=dev-gcp-cloudsql -json | jq -r .ip.value)`
- Adjust the `hostaddr` parameter to connect using `psql`:
  - Prod instance: `psql "sslmode=disable dbname=postgres user=root hostaddr=${prod_sql_ip}"`
  - Dev instance: `psql "sslmode=disable dbname=postgres user=root hostaddr=${dev_sql_ip}"`
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
