# Local required variables.
locals {
  # List that contains all DDoS rate policies.
  ratePolicies = flatten([ for policy in local.settings.security.policies : [ for name in policy.ratePolicies : { id: akamai_appsec_rate_policy.default[name].rate_policy_id, name: name, securityPolicyId: akamai_appsec_security_policy_default_protections.default[policy.name].security_policy_id } ] ])
}

# Definition of the DDoS rate policies.
resource "akamai_appsec_rate_policy" "default" {
  for_each    = { for ratePolicy in local.settings.security.sharedResources.ratePolicies : ratePolicy.name => ratePolicy }
  config_id   = akamai_appsec_configuration.default.config_id
  rate_policy = jsonencode(each.value)
  depends_on  = [ akamai_appsec_configuration.default ]
}

# Definition of the DDoS rate policies actions.
resource "akamai_appsec_rate_policy_action" "default" {
  for_each           = { for ratePolicy in local.ratePolicies : ratePolicy.name => ratePolicy }
  config_id          = akamai_appsec_configuration.default.config_id
  security_policy_id = each.value.securityPolicyId
  rate_policy_id     = each.value.id
  ipv4_action        = "deny"
  ipv6_action        = "deny"
  depends_on         = [
    akamai_appsec_configuration.default,
    akamai_appsec_security_policy_default_protections.default,
    akamai_appsec_rate_policy.default
  ]
}

# Definition of the DDoS slow post action.
resource "akamai_appsec_slow_post" "default" {
  for_each                   = { for policy in local.settings.security.policies : policy.name => policy }
  config_id                  = akamai_appsec_configuration.default.config_id
  security_policy_id         = akamai_appsec_security_policy_default_protections.default[each.key].security_policy_id
  slow_rate_action           = "abort"
  slow_rate_threshold_rate   = each.value.slowPost.rate
  slow_rate_threshold_period = each.value.slowPost.period
  depends_on                 = [
    akamai_appsec_configuration.default,
    akamai_appsec_security_policy_default_protections.default
  ]
}