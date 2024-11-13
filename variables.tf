variable "project_id" {
  description = "The project to deploy the ressources to."
  type        = string
}

variable "name" {
  description = "The load balancer name."
  type        = string

  validation {
    condition     = length(var.name) <= 50
    error_message = "The name variable must be shorter than 50 characters."
  }
}

variable "ip_address" {
  description = "The load balancer's IP address."
  type        = string
  default     = ""
  validation {
    condition     = try(regex("^([0-9]{1,3}.){3}[0-9]{1,3}$", var.ip_address), false) || var.ip_address == ""
    error_message = "Please provide a valid IP address."
  }
}

variable "ssl_certificates" {
  description = "A list of SSL certificates for the load balancer."
  type        = list(string)
  default     = []
}

variable "certificate_map_id" {
  description = <<EOF
    ID of a certificate map to attach to the load balancer. Must start with `//certificatemanager.googleapis.com/`
    This will exclude all other certificates that are configured on the loadbalancer.
    This is usefull when you want to preconfigure certificates before migration
    (https://cloud.google.com/certificate-manager/docs/deploy-google-managed-dns-auth#terraform_2).
    EOF
  type        = string
  default     = null
}

variable "buckets_backends" {
  description = "A map of buckets to add as the load balancer backends."
  type = map(object({
    hosts       = list(string)
    bucket_name = string
    cdn_policy  = optional(string)
    path_rules = list(object({
      paths = list(string)
    }))
    security_policy = optional(string)
  }))
}

variable "service_backends" {
  description = "A map of services to add as the load balancer backends. "
  type = map(object({
    hosts  = list(string)
    groups = list(string)
    path_rules = list(object({
      paths = list(string)
    }))
    security_policy = optional(string)
  }))
}

variable "custom_cdn_policies" {
  description = "A map of additional custom CDN policies you can add to the load balancer."
  type = map(object({
    cache_mode       = optional(string, null)
    client_ttl       = optional(number, null)
    default_ttl      = optional(number, null)
    max_ttl          = optional(number, null)
    negative_caching = optional(bool, null)
    negative_caching_policy = optional(map(object({
      code = optional(number, null)
      ttl  = optional(number, null)
    })), null)
    serve_while_stale            = optional(number, null)
    signed_url_cache_max_age_sec = optional(number, null)
  }))
  default = {}
}

variable "default_service_self_link" {
  description = "Override the default service of the load balancer. Should be the self_link of the service"
  type        = string
  default     = null
}

variable "advance_hosts_rules" {
  description = "Define a more advance URL map for the Loadbalancer. Should not be used in combinaison with service_backend and bucket_backend"
  type = map(object({
    hosts              = list(string)     # List of host that will be served by this host rule
    default_service_id = optional(string) # Default service id for this host rule
    path_rules = optional(list(object({
      paths      = list(string) # List of paths
      service_id = string       # Service id that will service those paths
    })))
  }))
}
