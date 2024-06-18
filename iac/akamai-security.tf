# Local required variables.
locals {
  # List that contains all hostnames to be onboarded in the security configuration.
  securityConfigurationHostnames = [ for property in local.settings.properties : property.hostname ]
}

# Definition of the security configuration.
resource "akamai_appsec_configuration" "default" {
  contract_id = local.settings.security.contract
  group_id    = local.settings.security.group
  name        = local.settings.security.name
  description = local.settings.security.description
  host_names  = local.securityConfigurationHostnames
}

# Definition of the SIEM settings.
resource "akamai_appsec_siem_settings" "default" {
  config_id               = akamai_appsec_configuration.default.config_id
  enable_siem             = true
  enable_botman_siem      = true
  enable_for_all_policies = true
  siem_id                 = 1
}

# Definition of the policies.
resource "akamai_appsec_security_policy_default_protections" "default" {
  for_each = { for  policy in local.settings.security.policies : policy.name => policy }

  config_id              = akamai_appsec_configuration.default.id
  security_policy_name   = each.key
  security_policy_prefix = each.value.prefix

  depends_on = [ akamai_appsec_configuration.default ]
}

# Definition of the match targets of a policy.
resource "akamai_appsec_match_target" "default" {
  for_each = { for policy in local.settings.security.policies : policy.name => policy }

  config_id    = akamai_appsec_configuration.default.id
  match_target = jsonencode(
    {
      "defaultFile" : "NO_MATCH",
      "hostnames" : compact([ for property in local.settings.properties : ( property.ruleType == each.value.ruleType ? property.hostname : null) ])
      "filePaths" : [ "/*" ],
      "bypassNetworkLists": local.bypassNetworkLists[each.key]
      "isNegativeFileExtensionMatch" : false,
      "isNegativePathMatch" : false,
      "securityPolicy" : {
        "policyId" : akamai_appsec_security_policy_default_protections.default[each.key].security_policy_id
      },
      "type" : "website",
      "sequence" : 0
    }
  )

  depends_on = [
    data.akamai_networklist_network_lists.default,
    akamai_appsec_configuration.default,
    akamai_appsec_security_policy_default_protections.default
  ]
}

# Fetches the security configuration metadata.
data "akamai_appsec_configuration" "default" {
  name = akamai_appsec_configuration.default.name

  depends_on = [ akamai_appsec_configuration.default ]
}

# Activates the security configuration in staging network.
resource "akamai_appsec_activations" "staging" {
  config_id           = akamai_appsec_configuration.default.config_id
  notification_emails = local.settings.general.notificationEmails
  network             = "STAGING"
  note                = local.settings.security.notes
  version             = data.akamai_appsec_configuration.default.latest_version

  depends_on = [
    akamai_appsec_configuration.default,
    akamai_appsec_siem_settings.default,
    akamai_appsec_rate_policy.default,
    akamai_appsec_security_policy_default_protections.default,
    akamai_appsec_match_target.default,
    data.akamai_networklist_network_lists.default,
    akamai_appsec_ip_geo.default,
    akamai_appsec_rate_policy_action.default,
    akamai_appsec_slow_post.default,
    data.akamai_appsec_configuration.default
  ]
}