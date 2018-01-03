init:
	cd master-region/ && terraform init

validate:
	terraform validate --check-variables=false master-region/

fmt:
	cd master-region/ terraform fmt -diff=true -check=true && cd ../

tflint:
	cd master-region/ && tflint --config=../.tflint.hcl --error-with-issues && cd ../
