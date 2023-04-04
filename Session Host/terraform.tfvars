# Customized the sample values below for your environment and either rename to terraform.tfvars or env.auto.tfvars

deploy_location      = "central india"
rg_name              = "avd-resources-rg"

prefix               = "avdtf"
local_admin_username = "localadm"
local_admin_password = "ChangeMe123$"
vnet_range           = ["10.1.0.0/16"]
       
dns_servers          = ["8.8.8.8", "10.1.0.4"]
aad_group_name       = "CTX_AAD_User_Access"
domain_name          = "amalcloud.xyz"
domain_user_upn      = "amal.abraham"     # do not include domain name as this is appended
domain_password      = "ChangeMe123!"
ad_vnet              = "RG_Compute-vnet"
ad_rg                = "RG_Compute"
avd_users = [
  "amal.abraham@amalcloud.xyz"
 
]