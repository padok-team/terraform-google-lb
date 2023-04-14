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
