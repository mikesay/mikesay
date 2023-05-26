## Terraform knowledge base
TBD

## Terraform learning materials

### Terraform use cases complex variables
https://blog.wimwauters.com/devops/2022-03-01_terraformusecases/

### Three of the most common iterator patterns 
https://github.com/recognizegroup/terraform  
Using for_each and a list of strings is the easiest to understand, you can always use the toset() function. When working with a list of objects you need to convert it to a map where the key is a unique value. The alternative is to put a map inside your Terraform configuration. Personally, I think it looks cleaner to have a list of objects instead of a map in your configuration. The key usually doesn't have a purpose other than to identify unique items in a map, which can thus be constructed dynamically. I also use iterators to conditionally deploy a resource or resource block, especially when constructing more complex modules.  

+ Using for_each on a list of strings  
```yaml
locals {
  ip_addresses = ["10.0.0.1", "10.0.0.2"]
}

resource "example" "example" {
  for_each   = toset(local.ip_addresses)
  ip_address = each.key
}
```

+ Using for_each on a list of objects  
```yaml
locals {
  virtual_machines = [
    {
      ip_address = "10.0.0.1"
      name       = "vm-1"
    },
    {
      ip_address = "10.0.0.1"
      name       = "vm-2"
    }
  ]
}    

resource "example" "example" {
  for_each   = {
    for index, vm in local.virtual_machines:
    vm.name => vm # Perfect, since VM names also need to be unique
    # OR: index => vm (unique but not perfect, since index will change frequently)
    # OR: uuid() => vm (do NOT do this! gets recreated everytime)
  }
  name       = each.value.name
  ip_address = each.value.ip_address
}
```

```yaml
resource "google_compute_instance" "node" {
    for_each = {for vm in var.vms:  vm.hostname => vm}

    name         = "${each.value.hostname}"
    machine_type = "custom-${each.value.cpu}-${each.value.ram*1024}"
    zone         = "${var.gcp_zone}"

    boot_disk {
        initialize_params {
        image = "${var.image_name}"
        size = "${each.value.hdd}"
        }
    }

    network_interface {
        network = "${var.network}"
    }

    metadata = {
        env_id = "${var.env_id}"
        service_types = "${join(",",each.value.service_types)}"
  }
}
```
It will create actual number of instance and when you remove for example middle one of three(if you create three:)), terraform will remove what we asked.

+ Using for_each as a conditional  
```yaml
variable "deploy_example" {
  type        = bool
  description = "Indicates whether to deploy something."
  default     = true
}

# Using count and a conditional, for_each is also possible here.
# See the next solution using a for_each with a conditional.
resource "example" "example" {
  count      = var.deploy_example ? 0 : 1
  name       = ...
  ip_address = ...
}

variable "enable_logs" {
  type        = bool
  description = "Indicates whether to enable something."
  default     = false
}

resource "example" "example" {
  name       = ...
  ip_address = ...

  # Note: dynamic blocks cannot use count!
  # Using for_each with an empty list and list(1) as a readable alternative. 
  dynamic "logs" {
    for_each = var.enable_logs ? [] : [1]
    content {
      name     = "logging"
    }
  }
}
```

