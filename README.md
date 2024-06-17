Getting Started
---------------

### Introduction
This is a project that has the intention to onboard multiple hostnames in Akamai using template (CDN & Security).
It automates (using **Terraform**) the provisioning of the following resources:

- **CP Code**: Identifier used for reporting and billing of the traffic. (Please check the file`iac/akamai-cpcode.tf` 
for more details).
- **Property**: Configuration that contains the CDN rules such as: caching, redirect, performance settings, etc. 
(Please check the file `iac/akamai-property.tf` for more details). 
- **Security**: Configuration that contains all security protections such as: Network Lists, DDoS, IP/GEO firewall, WAF, 
Bot Management, etc. (Please check the file `iac/akamai-security.tf` for more details).

### Requirements
- [`Terraform 1.5.x`](https://www.terraform.io) - IaC automation tool.
- `Any linux distribution with Kernel 5.x or later` or
- `MacOS - Catalina or later` or
- `MS-Windows 10 or later with WSL2`

### Documentation

All the Terraform files use `variables` that are stored in the `iac/variables.tf` and `iac/settings.json` so you are
able to customize the provisioning by changing these files.

The credentials (EdgeGrid) must be defined in `iac/.credentials` file or use its default location (`$HOME_DIR/.edgerc`).
You can customize the provisioning by editing these files. Please use the `iac/settings.json.template` as guidance.

The properties templates are defined in `iac/property/rules/<template_id>/*.json`
to tie the property with the security configuration/policy, you need to set the same value of the attribute `ruleType` 
in both settings.

Follow the documentation below to know more about Akamai:

- [**Akamai Techdocs**](https://techdocs.akamai.com)
- [**How to create Akamai EdgeGrid credentials**](https://techdocs.akamai.com/developer/docs/make-your-first-api-call)

### Important notes
- **If any phase got errors or violations, the pipeline will stop.**
- **DON'T EXPOSE OR COMMIT ANY SENSITIVE DATA, SUCH AS CREDENTIALS, IN THE PROJECT.**

### Contact
**LinkedIn:**
- https://www.linkedin.com/in/fvilarinho

**e-Mail:**
- fvilarin@akamai.com
- fvilarinho@gmail.com
- fvilarinho@outlook.com
- me@vila.net.br

and that's all! Have fun!