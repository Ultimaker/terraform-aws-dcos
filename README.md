# DC/OS on Amazon Web Services

This module provides a simple way to deploy a DC/OS cluster on AWS. It will deploy its 
machines and network configuration spread over all availability zones in a specific region.

The main goal of this project is to be modular, while providing an extremely high availability
setup. The way this module provides this high availability is the redundancy in its network
components. Availability zones should be as isolated as possible in terms of failure. 

## Getting Started

An example of how this module should be used is provided in the `example` directory in this 
project. We'll go through the basic steps to get a cluster up and running.

### Prerequisites 
- You should have Terraform installed.
- You should have a file located at `~/.aws/credentials` with your AWS access keys like this:
```
[default]
aws_access_key_id = MY_ACCESS_KEY_ID
aws_secret_access_key = MY_SECRET_ACCESS_KEY
```

### Running a cluster

First, check the `example/variables.tf` file and modify the `region` and `cluster_name` variables to your likings. 
The `region` variable should be a [region identifier as defined by Amazon Web Services](http://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region).
The `cluster_name` variable can contain any string you like. Please note that does not have to be unique
as we use a different variable as a unique identifier for the cluster.

Note that there is a `public_key` variable in the `example/variables.tf` file. This is a public key that
we will use to log into machines in our cluster. For purpose of this setup we'll create a new public/private
key pair that we'll use.

So create that public/private key pair.

```bash
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Remember where you saved the key pair. Now navigate to the `example` directory initialize the Terraform project.

```bash
$ cd example && terraform init
```

This will pull in `terraform-aws-dcos` and all its dependencies as modules. The only thing left to do is `apply`. We'll
throw in the contents of our public key in the command. Replace `~/.ssh/yourkey.pub` with the location you saved
your public key to.

```bash
$ terraform apply -var public_key="`cat ~/.ssh/yourkey.pub`"
```

Confirm that Terraform may apply the changes, and watch it spin up.

## Contributing

Contributions are of course welcome. Keep in mind that we have a few aims for this project:

- Everything that can fail, will fail. Design your features to survive a failure.
- We've kept the `dcos-config.yml` file and its rendering outside of the module. This is intentional 
to be as configurable as possible. All configuration parameters can be found in the 
[DC/OS documentation](https://dcos.io/docs/1.10/installing/custom/configuration/configuration-parameters/). 
If you need anything from within the module to use in your `dcos-config.yml`, please add the output to 
the module so you can use it in your rendering.

## Users

- [Ultimaker B.V.](https://ultimaker.com)
