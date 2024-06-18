# Definition of the CP Code used for reporting and billing.
resource "akamai_cp_code" "default" {
  for_each = { for property in local.settings.properties : property.name => property }

  contract_id = each.value.contract
  group_id    = each.value.group
  product_id  = each.value.product
  name        = each.key
}