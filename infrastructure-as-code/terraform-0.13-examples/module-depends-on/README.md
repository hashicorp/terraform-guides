# Module depends_on Example
This example illustrates the benefits of using the new `depends_on` argument in modules which is described [here](https://github.com/hashicorp/terraform/tree/guide-v0.13-beta/module-depends).

## Introduction
Prior to Terraform 0.13, module instances only served as namespaces for collections of resources and data sources. They were not nodes within Terraform's dependency graph. While it was possible in Terraform 0.12 to make a resource depend on a module, you could not make an entire module depend on a resource or on an entire module.

Terraform 0.13 addresses this by adding the new `depends_on` argument to the `module` blocks within your Terraform code.

In this example, we're going to use the [local_file](https://www.terraform.io/docs/providers/local/r/file.html) resource in one module, [write-files](./modules/write-files), to write 3 files (apple.txt, banana.txt, and orange.txt) to the root module's directory and then use the [local_file](https://www.terraform.io/docs/providers/local/d/file.html) data source in a second module, [read-files](./modules/read-files), to read the files and output their contents.

We will also use more complicated versions of these modules, [write-files-complicated](./modules/write-files-complicated) and [read-files-complicated](./modules/read-files-complicated), to show how module dependency could be faked in older versions of Terraform with out the `depends_on` argument of `module` blocks.

This is a trivial but useful example of using the `depends_on` argument of `module` blocks because the data sources that read the files have no direct dependency on the resources that write them. Obviously, we want Terraform to write the files in the first module before it tries to read them in the second module. Otherwise, we'll either get errors or read back empty files before their contents have been written.

## The Modules
The [main.tf](./modules/write-files/main.tf) file of the write-files module has this code:
```
resource "local_file" "apple" {
    content     = "apple"
    filename = "${path.root}/apple.txt"
}

resource "local_file" "banana" {
    content     = "banana"
    filename = "${path.root}/banana.txt"
}

resource "local_file" "orange" {
    content     = "orange"
    filename = "${path.root}/orange.txt"
}
```
It will create 3 files named after 3 different fruits. Each of these files will have the name of the fruit.

The [main.tf](./modules/read-files/main.tf) file of the read-files module has this code:
```
data "local_file" "apple" {
    filename = "${path.root}/apple.txt"
}

data "local_file" "banana" {
    filename = "${path.root}/banana.txt"
}

data "local_file" "orange" {
    filename = "${path.root}/orange.txt"
}

output "fruit" {
  value = [
    data.local_file.apple.content,
    data.local_file.banana.content,
    data.local_file.orange.content,
  ]
}
```
It will read the 3 files and then combine their content in an output of type list. When the code works as desired, the output should show this:
```
fruit = [
  "apple",
  "banana",
  "orange",
]
```

## First Attempt (Hope for the Best)
We're going to start out with a naive "hope for the best" approach that does not try to tell Terraform anything about the required dependency between the modules or their resources.

If you inspect the [main-1.tf](./main-1.tf) file, you'll see it has this code:
```
module "write-files" {
  source = "./modules/write-files"
}

module "read-files" {
  source = "./modules/read-files"
}

output "fruit" {
  value = module.read-files.fruit
}
```
It references the write-files and read-files modules and then tries to generate an output from the latter.

Please do the following:
1. Navigate to the terraform-0.13-examples/module-depends-on directory of this repository in your clone of it.
1. Run `terraform init`. This should succeed.
1. Run `terraform plan`.

This should refresh all 3 data sources in the read-files module and give 3 errors like this:

```
module.read-files.data.local_file.orange: Refreshing state...
module.read-files.data.local_file.apple: Refreshing state...
module.read-files.data.local_file.banana: Refreshing state...

Error: open ./apple.txt: no such file or directory

  on modules/read-files/main.tf line 5, in data "local_file" "apple":
   5: data "local_file" "apple" {

Error: open ./banana.txt: no such file or directory

  on modules/read-files/main.tf line 9, in data "local_file" "banana":
   9: data "local_file" "banana" {

Error: open ./orange.txt: no such file or directory

  on modules/read-files/main.tf line 13, in data "local_file" "orange":
  13: data "local_file" "orange" {
```

The problem is that Terraform could not find the files while refreshing the data sources.

You can partially address this problem by writing out empty versions of the files with these commands:
```
touch apple.txt
touch banana.txt
touch orange.txt
```

Then run `terraform apply`. This will show the following:
```
module.read-files.data.local_file.apple: Refreshing state...
module.read-files.data.local_file.banana: Refreshing state...
module.read-files.data.local_file.orange: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.write-files.local_file.apple will be created
  + resource "local_file" "apple" {
      + content              = "apple"
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./apple.txt"
      + id                   = (known after apply)
    }

  # module.write-files.local_file.banana will be created
  + resource "local_file" "banana" {
      + content              = "banana"
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./banana.txt"
      + id                   = (known after apply)
    }

  # module.write-files.local_file.orange will be created
  + resource "local_file" "orange" {
      + content              = "orange"
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./orange.txt"
      + id                   = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Note that the data sources were still refreshed during the plan that `terraform apply` automatically runs. However, since Terraform did find files, it was able to successfully run the plan and has asked if you want to apply.

Please type "yes" and click your <return\> button.

You should now see this:
```
module.write-files.local_file.banana: Creating...
module.write-files.local_file.orange: Creating...
module.write-files.local_file.apple: Creating...
module.write-files.local_file.orange: Creation complete after 0s [id=ef0ebbb77298e1fbd81f756a4efc35b977c93dae]
module.write-files.local_file.apple: Creation complete after 0s [id=d0be2dc421be4fcd0172e5afceea3970e2f3d940]
module.write-files.local_file.banana: Creation complete after 0s [id=250e77f12a5ab6972a0895d290c4792f0a326ea8]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

fruit = [
  "",
  "",
  "",
]
```

This is almost what we want, but the output shows that we are missing the text from the files. So, creating empty versions of the file before doing the apply did not really help.

Please run `terraform destroy` and type "yes" when asked if you want to destroy all resources.

## Second Attempt (Fake Module Dependencies)
Now, we'll show how you could successfully read the fruit files after writing them without the `depends_on` argument of the `module` block. We'll do this by faking module dependencies.

The [main.tf](./modules/write-files-complicated/main.tf) file of the write-files-complicated module has the same code as the write-files module except that it adds this output:
```
output "write_done" {
  value = "apples, bananas, and oranges"
}
```

The [main.tf](./modules/read-files-complicated/main.tf) file of the read-files-complicated module is more complicated, having this code:
```
variable "wait_for_write" {}

resource "null_resource" "dependency" {
  triggers = {
    dependency_id = var.wait_for_write
  }

}

data "local_file" "apple" {
    filename = "${path.root}/apple.txt"
    depends_on = [null_resource.dependency]
}

data "local_file" "banana" {
    filename = "${path.root}/banana.txt"
    depends_on = [null_resource.dependency]
}

data "local_file" "orange" {
    filename = "${path.root}/orange.txt"
    depends_on = [null_resource.dependency]
}

output "fruit" {
  value = [
    data.local_file.apple.content,
    data.local_file.banana.content,
    data.local_file.orange.content,
  ]
}
```
Note the following changes:
1. It adds the `wait_for_write` variable.
1. It adds a null resource that references the variable.
1. Each of the `local_file` data sources has a `depends_on` argument that references the null resource.
These things were added to make sure that none of the data sources could be created and read before the variable is given a value and the null resource is created.  And that will not be possible until after the write-files-complicated module has finished writing the files.

If you inspect the [main-2.tf.txt](./main-2.tf.txt) file, you'll see it has this code:
```
module "write-files-complicated" {
  source = "./modules/write-files-complicated"
}

module "read-files-complicated" {
  source = "./modules/read-files-complicated"
  wait_for_write = module.write-files-complicated.write_done
}

output "fruit" {
  value = module.read-files-complicated.fruit
}
```
Note that this is similar to main-1.tf, but we are now using the more complicated modules and are also setting the value of the `wait_for_write` variable of the read-files-complicated module to the `write_done` output of the write-files-complicated module. This is key for establishing the dependency we want.

Please do the following:
1. Run `mv main-1.tf main-1.tf.txt` (for Mac of Linux) or `ren main-1.tf main-1.tf.txt` (for Windows).
1. Run `mv main-2.tf.txt main-2.tf` (for Mac of Linux) or `ren main-2.tf.txt main-2.tf` (for Windows).
1. Run `terraform init`.
1. Run `terraform apply` and type "yes" when prompted.

Note that the plan done by the apply will show 3 messages like the following:
```
# module.read-files.data.local_file.apple will be read during apply
# (config refers to values not yet known)
<= data "local_file" "apple"  {
    + content        = (known after apply)
    + content_base64 = (known after apply)
    + filename       = "./apple.txt"
    + id             = (known after apply)
  }
```
This indicates that the data sources will be read during the apply instead of during the plan done by the apply. That is progress!

After typing "yes" and clicking your <return\> key, you should see the following:
```
module.write-files.local_file.apple: Creating...
module.write-files.local_file.orange: Creating...
module.write-files.local_file.banana: Creating...
module.read-files.null_resource.dependency: Creating...
module.read-files.null_resource.dependency: Creation complete after 0s [id=3550826611686779518]
module.write-files.local_file.orange: Creation complete after 0s [id=ef0ebbb77298e1fbd81f756a4efc35b977c93dae]
module.read-files.data.local_file.banana: Reading...
module.read-files.data.local_file.orange: Reading...
module.read-files.data.local_file.apple: Reading...
module.read-files.data.local_file.banana: Read complete after 0s [id=250e77f12a5ab6972a0895d290c4792f0a326ea8]
module.read-files.data.local_file.apple: Read complete after 0s [id=d0be2dc421be4fcd0172e5afceea3970e2f3d940]
module.read-files.data.local_file.orange: Read complete after 0s [id=ef0ebbb77298e1fbd81f756a4efc35b977c93dae]
module.write-files.local_file.apple: Creation complete after 0s [id=d0be2dc421be4fcd0172e5afceea3970e2f3d940]
module.write-files.local_file.banana: Creation complete after 0s [id=250e77f12a5ab6972a0895d290c4792f0a326ea8]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

fruit = [
  "apple",
  "banana",
  "orange",
]
```
Note that the reads are done in the apply **after** the writes and that the `fruit` output has the desired names of the 3 fruits. So, this approach has succeeded.

However, it was a bit painful because we had to add an extraneous variable, an extraneous output, an extraneous null resource, and 3 `depends_on` arguments.

Please run `terraform destroy` before continuing to the last variation in this example.

## Third Attempt (Use the New Module `depends_on` Argument)
Now, we'll finally show you how much easier creating dependencies between modules is with the new `depends_on` argument of `module` blocks.

If you inspect the [main-3.tf.txt](./main-3.tf.txt) file, you'll see it has this code:
```
module "write-files" {
  source = "./modules/write-files"
}

module "read-files" {
  source = "./modules/read-files"
  depends_on = [module.write-files]
}

output "fruit" {
  value = module.read-files.fruit
}
```
Note the use of the new `depends_on` argument in the second module block. Also note that we have reverted to using the simpler write-files and read-files modules.

Please do the following:
1. Run `mv main-2.tf main-2.tf.txt` (for Mac of Linux) or `ren main-2.tf main-2.tf.txt` (for Windows).
1. Run `mv main-3.tf.txt main-3.tf` (for Mac of Linux) or `ren main-3.tf.txt main-3.tf` (for Windows).
1. Run `terraform init`.
1. Run `terraform apply` and type "yes" when prompted.

The apply will give the following output:
```
module.write-files.local_file.apple: Creating...
module.write-files.local_file.orange: Creating...
module.write-files.local_file.banana: Creating...
module.write-files.local_file.banana: Creation complete after 0s [id=250e77f12a5ab6972a0895d290c4792f0a326ea8]
module.write-files.local_file.orange: Creation complete after 0s [id=ef0ebbb77298e1fbd81f756a4efc35b977c93dae]
module.write-files.local_file.apple: Creation complete after 0s [id=d0be2dc421be4fcd0172e5afceea3970e2f3d940]
module.read-files.data.local_file.apple: Reading...
module.read-files.data.local_file.orange: Reading...
module.read-files.data.local_file.banana: Reading...
module.read-files.data.local_file.orange: Read complete after 0s [id=ef0ebbb77298e1fbd81f756a4efc35b977c93dae]
module.read-files.data.local_file.apple: Read complete after 0s [id=d0be2dc421be4fcd0172e5afceea3970e2f3d940]
module.read-files.data.local_file.banana: Read complete after 0s [id=250e77f12a5ab6972a0895d290c4792f0a326ea8]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

fruit = [
  "apple",
  "banana",
  "orange",
]
```

Note that the reads were done after the writes and that the output shows the names of the 3 fruits as desired.

While the result is quite similar to our second attempt, the code is less complex.  We did not need to create extraneous objects and only needed one `depends_on` argument, this time at the module level instead of on each data source of the second module.

Finally, run `terraform destroy` and type "yes" when prompted to destroy the files that were created.
