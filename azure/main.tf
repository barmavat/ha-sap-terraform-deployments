module "local_execution" {
  source  = "../generic_modules/local_exec"
  enabled = var.pre_deployment
}

locals {
  iscsi_ip              = var.iscsi_srv_ip != "" ? var.iscsi_srv_ip : cidrhost(local.subnet_address_range, 1)
  monitoring_ip         = var.monitoring_srv_ip != "" ? var.monitoring_srv_ip : cidrhost(local.subnet_address_range, 2)
  hana_ips              = length(var.host_ips) != 0 ? var.host_ips : [for ip_index in range(3, var.hana_count + 3): cidrhost(local.subnet_address_range, ip_index)]
  hana_cluster_vip      = var.hana_cluster_vip != "" ? var.hana_cluster_vip : cidrhost(local.subnet_address_range, 5)
  drbd_ips              = length(var.drbd_ips) != 0 ? var.drbd_ips : [for ip_index in range(6, 8): cidrhost(local.subnet_address_range, ip_index)]
  drbd_cluster_vip      = var.drbd_cluster_vip != "" ? var.drbd_cluster_vip : cidrhost(local.subnet_address_range, 8)
  netweaver_ips         = length(var.netweaver_ips) != 0 ? var.netweaver_ips : [for ip_index in range(9, 13): cidrhost(local.subnet_address_range, ip_index)]
  netweaver_virtual_ips = length(var.netweaver_virtual_ips) != 0 ? var.netweaver_virtual_ips : [for ip_index in range(13, 17): cidrhost(local.subnet_address_range, ip_index)]
}

module "drbd_node" {
  source                 = "./modules/drbd_node"
  az_region              = var.az_region
  drbd_count             = var.drbd_enabled == true ? 2 : 0
  vm_size                = var.drbd_vm_size
  drbd_image_uri         = var.drbd_image_uri
  drbd_public_publisher  = var.drbd_public_publisher
  drbd_public_offer      = var.drbd_public_offer
  drbd_public_sku        = var.drbd_public_sku
  drbd_public_version    = var.drbd_public_version
  resource_group_name    = local.resource_group_name
  network_subnet_id      = local.subnet_id
  sec_group_id           = azurerm_network_security_group.mysecgroup.id
  storage_account        = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  public_key_location    = var.public_key_location
  private_key_location   = var.private_key_location
  cluster_ssh_pub        = var.cluster_ssh_pub
  cluster_ssh_key        = var.cluster_ssh_key
  admin_user             = var.admin_user
  host_ips               = local.drbd_ips
  iscsi_srv_ip           = module.iscsi_server.iscsisrv_ip.0
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  devel_mode             = var.devel_mode
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
  drbd_cluster_vip       = local.drbd_cluster_vip
}

module "netweaver_node" {
  source                        = "./modules/netweaver_node"
  az_region                     = var.az_region
  vm_size                       = var.netweaver_vm_size
  data_disk_caching             = var.netweaver_data_disk_caching
  data_disk_size                = var.netweaver_data_disk_size
  data_disk_type                = var.netweaver_data_disk_type
  netweaver_count               = var.netweaver_enabled == true ? 4 : 0
  netweaver_image_uri           = var.netweaver_image_uri
  netweaver_public_publisher    = var.netweaver_public_publisher
  netweaver_public_offer        = var.netweaver_public_offer
  netweaver_public_sku          = var.netweaver_public_sku
  netweaver_public_version      = var.netweaver_public_version
  resource_group_name           = local.resource_group_name
  network_subnet_id             = local.subnet_id
  sec_group_id                  = azurerm_network_security_group.mysecgroup.id
  storage_account               = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  public_key_location           = var.public_key_location
  private_key_location          = var.private_key_location
  cluster_ssh_pub               = var.cluster_ssh_pub
  cluster_ssh_key               = var.cluster_ssh_key
  admin_user                    = var.admin_user
  netweaver_product_id          = var.netweaver_product_id
  netweaver_swpm_folder         = var.netweaver_swpm_folder
  netweaver_sapcar_exe          = var.netweaver_sapcar_exe
  netweaver_swpm_sar            = var.netweaver_swpm_sar
  netweaver_swpm_extract_dir    = var.netweaver_swpm_extract_dir
  netweaver_sapexe_folder       = var.netweaver_sapexe_folder
  netweaver_additional_dvds     = var.netweaver_additional_dvds
  netweaver_nfs_share           = "${local.drbd_cluster_vip}:/HA1" # drbd cluster ip address is hardcoded by now
  storage_account_name          = var.netweaver_storage_account_name
  storage_account_key           = var.netweaver_storage_account_key
  storage_account_path          = var.netweaver_storage_account
  enable_accelerated_networking = var.netweaver_enable_accelerated_networking
  host_ips                      = local.netweaver_ips
  virtual_host_ips              = local.netweaver_virtual_ips
  iscsi_srv_ip                  = module.iscsi_server.iscsisrv_ip.0
  hana_ip                       = local.hana_cluster_vip
  reg_code                      = var.reg_code
  reg_email                     = var.reg_email
  reg_additional_modules        = var.reg_additional_modules
  ha_sap_deployment_repo        = var.ha_sap_deployment_repo
  devel_mode                    = var.devel_mode
  provisioner                   = var.provisioner
  background                    = var.background
  monitoring_enabled            = var.monitoring_enabled
}

module "hana_node" {
  source                        = "./modules/hana_node"
  az_region                     = var.az_region
  hana_count                    = var.hana_count
  hana_instance_number          = var.hana_instance_number
  vm_size                       = var.hana_vm_size
  host_ips                      = local.hana_ips
  scenario_type                 = var.scenario_type
  resource_group_name           = local.resource_group_name
  network_subnet_id             = local.subnet_id
  sec_group_id                  = azurerm_network_security_group.mysecgroup.id
  storage_account               = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  storage_account_name          = var.storage_account_name
  storage_account_key           = var.storage_account_key
  enable_accelerated_networking = var.hana_enable_accelerated_networking
  sles4sap_uri                  = var.sles4sap_uri
  init_type                     = var.init_type
  hana_cluster_vip              = local.hana_cluster_vip
  hana_inst_master              = var.hana_inst_master
  hana_inst_folder              = var.hana_inst_folder
  hana_platform_folder          = var.hana_platform_folder
  hana_sapcar_exe               = var.hana_sapcar_exe
  hdbserver_sar                 = var.hdbserver_sar
  hana_extract_dir              = var.hana_extract_dir
  hana_disk_device              = var.hana_disk_device
  hana_fstype                   = var.hana_fstype
  cluster_ssh_pub               = var.cluster_ssh_pub
  cluster_ssh_key               = var.cluster_ssh_key
  public_key_location           = var.public_key_location
  private_key_location          = var.private_key_location
  hana_data_disk_type           = var.hana_data_disk_type
  hana_data_disk_size           = var.hana_data_disk_size
  hana_data_disk_caching        = var.hana_data_disk_caching
  hana_public_publisher         = var.hana_public_publisher
  hana_public_offer             = var.hana_public_offer
  hana_public_sku               = var.hana_public_sku
  hana_public_version           = var.hana_public_version
  admin_user                    = var.admin_user
  iscsi_srv_ip                  = module.iscsi_server.iscsisrv_ip.0
  reg_code                      = var.reg_code
  reg_email                     = var.reg_email
  reg_additional_modules        = var.reg_additional_modules
  additional_packages           = var.additional_packages
  ha_sap_deployment_repo        = var.ha_sap_deployment_repo
  devel_mode                    = var.devel_mode
  provisioner                   = var.provisioner
  background                    = var.background
  monitoring_enabled            = var.monitoring_enabled
  hwcct                         = var.hwcct
  qa_mode                       = var.qa_mode
}

module "monitoring" {
  source                      = "./modules/monitoring"
  az_region                   = var.az_region
  vm_size                     = var.monitoring_vm_size
  resource_group_name         = local.resource_group_name
  network_subnet_id           = local.subnet_id
  sec_group_id                = azurerm_network_security_group.mysecgroup.id
  storage_account             = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  monitoring_uri              = var.monitoring_uri
  monitoring_public_publisher = var.monitoring_public_publisher
  monitoring_public_offer     = var.monitoring_public_offer
  monitoring_public_sku       = var.monitoring_public_sku
  monitoring_public_version   = var.monitoring_public_version
  monitoring_srv_ip           = local.monitoring_ip
  public_key_location         = var.public_key_location
  private_key_location        = var.private_key_location
  admin_user                  = var.admin_user
  host_ips                    = local.hana_ips
  reg_code                    = var.reg_code
  reg_email                   = var.reg_email
  reg_additional_modules      = var.reg_additional_modules
  additional_packages         = var.additional_packages
  ha_sap_deployment_repo      = var.ha_sap_deployment_repo
  provisioner                 = var.provisioner
  background                  = var.background
  monitoring_enabled          = var.monitoring_enabled
  drbd_enabled                = var.drbd_enabled
  drbd_ips                    = local.drbd_ips
  netweaver_enabled           = var.netweaver_enabled
  netweaver_ips               = local.netweaver_virtual_ips
}

module "iscsi_server" {
  source                 = "./modules/iscsi_server"
  az_region              = var.az_region
  vm_size                = var.iscsi_vm_size
  resource_group_name    = local.resource_group_name
  network_subnet_id      = local.subnet_id
  sec_group_id           = azurerm_network_security_group.mysecgroup.id
  storage_account        = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  iscsi_srv_uri          = var.iscsi_srv_uri
  iscsi_public_publisher = var.iscsi_public_publisher
  iscsi_public_offer     = var.iscsi_public_offer
  iscsi_public_sku       = var.iscsi_public_sku
  iscsi_public_version   = var.iscsi_public_version
  public_key_location    = var.public_key_location
  private_key_location   = var.private_key_location
  iscsidev               = var.iscsidev
  iscsi_disks            = var.iscsi_disks
  admin_user             = var.admin_user
  iscsi_srv_ip           = local.iscsi_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  additional_packages    = var.additional_packages
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  background             = var.background
  qa_mode                = var.qa_mode
}
