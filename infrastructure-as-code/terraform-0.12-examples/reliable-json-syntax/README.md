# Reliable JSON Syntax Example
This example illustrates how the new [Reliable JSON Syntax](https://www.hashicorp.com/blog/terraform-0-12-reliable-json-syntax) makes life easier for customers using Terraform JSON files instead of HCL files.

As you work through this example, you will need to change the extensions of the files so that only one has the `tf.json` extension at any time. Be sure to change the extension to "tf.json" rather than to "tf".

Also, if you run `terraform init`, you will be prompted to run the `terraform 0.12upgrade` or `terraform validate` command.  So, for this example, just run `terraform validate` for each file.

Let's start by comparing the errors given for this JSON by Terraform 0.11.10 and 0.12:

variable1.tf.json
```
{
  "variable": {
    "example": "foo"
  }
}
```
Running `terraform validate` with Terraform 0.11.10 gives:
```
Error: Error loading /home/ubuntu/test_json/variable1.tf.json: -: "variable" must be followed by a name
```

Terraform 0.12 gives:
```
Error: Incorrect JSON value type

  on variable1.tf.json line 3, in variable:
   3:     "example": "foo"

Either a JSON object or a JSON array is required, representing the contents of
one or more "variable" blocks.
```

The latter is better for two reasons:
1. It gives us the line number for which the error occurred.
1. It tells us that Terraform knew we were defining a Terraform variable and that a variable needs certain things to be legitimate.

While the Terraform 0.11.10 error is telling us we need a name, that is not really true and it is not clear where we would add a name. We could try this:

variable2.tf.json
```
{
  "variable": "name" {
    "example": "foo"
  }
}
```
But this gives us other errors.

We could also try this:

variable3.tf.json
```
{
  "variable": {
    "name": "foo",
    "example": "foo"
  }
}
```
But we again get errors.

Now, let's follow the advice that the first Terraform 0.12 error gave us which was to add a JSON object or array:

variable4.tf.json
```
{
  "variable": {
    "example": {
      "label": "foo"
    }
  }
}
```

Running `terraform validate` with Terraform 0.11.10 gives:
```
Error: Error loading /home/ubuntu/test_json/variable4.tf.json: 1 error(s) occurred:

* variable[example]: invalid key: label
```

Terraform 0.12 gives:
```
Error: Extraneous JSON object property

on variable4.tf.json line 4, in variable.example:
 4:       "label": "foo"

No argument or block type is named "label".
```

Both of these errors are telling us that "label" is not a valid atribute for a variable. If we look at the [variables](https://www.terraform.io/docs/configuration/variables.html) documentation, we see that the valid arguments for a Terraform variable are type, default, and description.

So, let's try changing "label" to "default" so that we have this:

variable-correct.tf.json
```
{
  "variable": {
    "example": {
      "default": "foo"
    }
  }
}
```

Now running `terraform validate` runs without error for both Terraform 0.11.10 and 0.12.

Additionally, we can even now include comments in our JSON code:

variable-with-comment.tf.json
```
{
  "variable": {
    "example": {
      "//": "This property is a comment and ignored",
      "default": "foo"
    }
  }
}
```
While Terraform 0.11.10 complains about this, saying that "//" is an invalid key, Terraform 0.12 accepts and ignores the comment.

In summary, the error messages for parsing Terraform JSON configuraitons are much improved over those that were given in earlier versions of Terraform.
