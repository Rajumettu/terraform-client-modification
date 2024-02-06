# terraform-client-modification
Task3-- API Keys Not Rotated Within 90 Days
Prerequisite--- 
1- write  a code to perform the checking access key rotation
2- Must have the IAM user whose access key is to be checked
Solution-- Put your lamda function code in zip file and provide the location specified in APIkey_rotation.tf. Now put your access key and secret key in provider.tf.
commands to be run---- 1- terraform init
                       2- terraform plan
                       3- terraform apply --auto-approve
--------------------------------------------
Task4-- to check the status static website enabled on s3 bucket and if not enbled, then  add the polity in s3 bucket
Prerequisite---
1- have a preexixting s3 bucket name
Solution-- Put the name of your existing s3 bucket in staticwebsite.tf
Now, just run the terraform init, terraform plan and terraform apply --auto-approve
---------------------------------------------------------------------------------------
