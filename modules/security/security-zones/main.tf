# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

locals {
    
    
    cis_1_2_L2 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa5ocyo7jqjzgjenvccch46buhpaaofplzxlp3xbxfcdwwk2tyrwqa",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaauoi2xnbusvfd4yffdjaaazk64gndp4flumaw3r7vedwndqd6vmrq"
                        ]
    cis_1_2_L1 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa7pgtjyod3pze6wuylgmts6ensywmeplabsxqq2bk4ighps4fqq4a", 
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaxxs63ulmtcnxqmcvy6eaozh5jdtiaa2bk7wll5bbdsbnmmoczp5a",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaqmq4jqcxqbjj5cjzb7t5ira66dctyypq2m2o4psxmx6atp45lyda",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaff6n52aojbgdg46jpm3kn7nizmh6iwvr7myez7svtfxsfs7irigq",
    ]

    sz_policies = var.cis_level == "2" ? setunion(local.cis_1_2_L2,local.cis_1_2_L1,var.security_policies) : setunion(local.cis_1_2_L1,var.security_policies)

  security_zones = {
    for k, v in var.security_zones : k => {
      name = v.name
      tenancy_ocid = v.tenancy_ocid
      service_label = v.service_label
      description   = v.description
      security_policies = coalesce(v.security_policies,[])
      cis_level         = coalesce(v.cis_level,"2")
      defined_tags      = v.defined_tags
      freeform_tags     = v.freeform_tags
    }
  }

}


resource "oci_cloud_guard_security_recipe" "this" {
    #Required
    compartment_id = var.compartment_id
    display_name = var.description
    security_policies = local.sz_policies

    #Optional
    defined_tags = var.defined_tags
    description = "${var.description} recipe."
    freeform_tags = var.freeform_tags
}

resource "oci_cloud_guard_security_zone" "this" {
    #Required
    # depends_on = [ oci_cloud_guard_security_recipe]
    compartment_id = var.compartment_id
    display_name = var.description
    security_zone_recipe_id = oci_cloud_guard_security_recipe.this.id

    #Optional
    defined_tags = var.defined_tags
    description = "${var.description}."
    freeform_tags = var.freeform_tags
}