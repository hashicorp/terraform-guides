# AWS S3 Buckets, Bucket Policies, and IAM Policy Documents

The Terraform code in this directory was used to generate some S3 buckets,
S3 bucket policies, and an IAM policy document in order to run a plan and
generate Sentinel mocks for use with the [restrict-s3-bucket-policies.sentinel](../governance/third-generation/restrict-s3-bucket-policies.sentinel)
Sentinel policy.

That policy requires all S3 buckets created with the `aws_s3_bucket` resource and
all S3 bucket policies created with the `aws_s3_bucket_policy` resource to set
their `policy` argument to an instance of the `aws_iam_policy_document` data
source if they set it at all. The policy also restricts policy documents within
`aws_iam_policy_document` data sources that certain S3 actions like "s3:ListBucket",
"s3:GetObject", and "s3:PutObject" to include statements with conditions that
mandate access over HTTPS and from specific VPC endpoints.

Mandating the use of the `aws_iam_policy_document` data source in IAM policies set
in S3 buckets and other AWS resources is useful when using Sentinel since each
element of the policy documents created with that data source are given in their
own distinct attributes. This allows Sentinel to see many elements of the policy
document even if some of them are marked as computed because they refer to
attributes of other resources that won't be known until the apply is run. In
contrast, when you embed a policy directly inside the `policy` attribute of an S3
bucket or S3 bucket policy resource, if any element of the policy refers to an
attribute of some other resource that will not be known until the apply is run,
then the entire policy ends up being marked as computed ("known after apply") and
it is then completely opaque to Sentinel.

The Terraform code in main.tf intentionally creates some buckets and bucket
policies that will fail the restrict-s3-bucket-policies.sentinel policy. When I
created the test cases for that policy, I copied the generated Sentinel mocks
multiple times and then edited them to leave in only the instances of S3 buckets,
S3 bucket policies, and IAM policy documents needed by each test case.
