# Local required variables.
locals {
  # List that contains all network lists names.
  allNetworkListsNames        = concat(local.bypassNetworkListsNames, local.blockedGeoNetworkListsNames, local.blockedIPNetworkListsNames, local.exceptionsListsNames)
  bypassNetworkListsNames     = flatten([ for policy in local.settings.security.policies : [ for name in policy.bypassNetworkLists : name ] ])
  blockedGeoNetworkListsNames = flatten([ for policy in local.settings.security.policies : [ for name in policy.blockedGeoNetworkLists : name ] ])
  blockedIPNetworkListsNames  = flatten([ for policy in local.settings.security.policies : [ for name in policy.blockedIPNetworkLists : name ] ])
  exceptionsListsNames        = flatten([ for policy in local.settings.security.policies : [ for name in policy.exceptionsLists : name ] ])

  # List that contains all network lists IDs (The provisioning only accepts IDs).
  bypassNetworkLists     = { for policy in local.settings.security.policies : policy.name => [ for name in policy.bypassNetworkLists : { id: data.akamai_networklist_network_lists.default[name].id, name: name } ] }
  blockedGeoNetworkLists = { for policy in local.settings.security.policies : policy.name => [ for name in policy.blockedGeoNetworkLists : data.akamai_networklist_network_lists.default[name].id ] }
  blockedIPNetworkLists  = { for policy in local.settings.security.policies : policy.name => [ for name in policy.blockedIPNetworkLists : data.akamai_networklist_network_lists.default[name].id ] }
  exceptionsLists        = { for policy in local.settings.security.policies : policy.name => [ for name in policy.exceptionsLists : data.akamai_networklist_network_lists.default[name].id ] }
}

# Fetches the metadata of network lists used in the security configuration.
data "akamai_networklist_network_lists" "default" {
  for_each = toset(local.allNetworkListsNames)
  name     = each.key
}

# Definition of the IP/GEO Firewall.
resource "akamai_appsec_ip_geo" "default" {
  for_each                   = { for policy in local.settings.security.policies : policy.name => policy }
  config_id                  = akamai_appsec_configuration.default.config_id
  security_policy_id         = akamai_appsec_security_policy_default_protections.default[each.key].security_policy_id
  mode                       = "block"
  ukraine_geo_control_action = "none"
  geo_network_lists          = local.blockedGeoNetworkLists[each.key]
  ip_network_lists           = local.blockedIPNetworkLists[each.key]
  exception_ip_network_lists = local.exceptionsLists[each.key]
  depends_on                 = [
    data.akamai_networklist_network_lists.default,
    akamai_appsec_configuration.default,
    akamai_appsec_security_policy_default_protections.default
  ]
}