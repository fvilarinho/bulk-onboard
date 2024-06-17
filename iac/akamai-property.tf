# Definition of the property rules (CDN configuration).
data "akamai_property_rules_template" "default" {
  for_each      = { for property in local.settings.properties : property.name => property }
  template_file = abspath("property/rules/${each.value.ruleType}/main.json")

  # Definition of the origin hostname.
  variables {
    name  = "originHostname"
    type  = "string"
    value = each.value.originHostname
  }

  # Definition of the CP Code.
  variables {
    name  = "cpCode"
    type  = "number"
    value = replace(akamai_cp_code.default[each.key].id, "cpc_", "")
  }

  # Definition of the SiteShield map.
  variables {
    name  = "siteShield"
    type = "jsonBlock"
    value = jsonencode(each.value.siteShield)
  }

  # Definition of the SureRoute.
  variables {
    name  = "sureRoute"
    type = "jsonBlock"
    value = jsonencode(each.value.sureRoute)
  }

  depends_on = [ akamai_cp_code.default ]
}

# Definition of the property (CDN configuration).
resource "akamai_property" "default" {
  for_each    = { for property in local.settings.properties : property.name => property }
  contract_id = each.value.contract
  group_id    = each.value.group
  product_id  = each.value.product
  name        = each.key
  rules       = data.akamai_property_rules_template.default[each.key].json

  hostnames {
    cert_provisioning_type = "CPS_MANAGED"
    cname_from             = each.value.hostname
    cname_to               = each.value.edgeHostname
  }

  depends_on = [ data.akamai_property_rules_template.default ]
}

# Activates the property in staging network.
resource "akamai_property_activation" "staging" {
  for_each                       = { for property in local.settings.properties : property.name => property }
  property_id                    = akamai_property.default[each.key].id
  version                        = akamai_property.default[each.key].latest_version
  contact                        = local.settings.general.notificationEmails
  note                           = local.settings.general.notes
  auto_acknowledge_rule_warnings = true
  network                        = "STAGING"
}