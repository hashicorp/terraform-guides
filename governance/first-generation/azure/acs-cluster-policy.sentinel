import "tfplan"

clusters = tfplan.resources.azurerm_container_service

agent_node_count_limit = rule {
  all clusters as name, instances {
    all instances as index, r {
      int(r.applied.agent_pool_profile[0].count) < 10
    }
  }
}

master_node_count_limit = rule {
  all clusters as name, instances {
    all instances as index, r {
      int(r.applied.master_profile[0].count) <= 3
    }
  }
}

vm_size_allowed = rule {
  all clusters as name, instances {
    all instances as index, r {
  	  r.applied.agent_pool_profile[0].vm_size matches "Standard_A1"
    }
  }
}
main = rule {
  (master_node_count_limit and agent_node_count_limit and vm_size_allowed) else true
}
