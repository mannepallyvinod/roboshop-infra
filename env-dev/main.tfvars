env = "dev"
bastion_cidr = ["172.31.26.66/32"]

dns_domain = "deepdivers.xyz"


## VPC Modules to create public and private subnets multiple availability zones
vpc = {
  main = {
    vpc_cidr = "10.0.0.0/16"

    public_subnets = {
      public-az1 = {
        name = "public-az1"
        cidr_block = "10.0.0.0/24"
        availability_zone = "us-east-1a"
      }
      public-az2 = {
        name       = "public-az2"
        cidr_block = "10.0.1.0/24"
        availability_zone = "us-east-1b"
      }
    }
    private_subnets = {
      web-az1 = {
        name = "web-az1"
        cidr_block = "10.0.2.0/24"
        availability_zone = "us-east-1a"
      }
      web-az2 = {
        name       = "web-az2"
        cidr_block = "10.0.3.0/24"
        availability_zone = "us-east-1b"
      }
      app-az1 = {
        name = "app-az1"
        cidr_block = "10.0.4.0/24"
        availability_zone = "us-east-1a"
      }
      app-az2 = {
        name       = "app-az2"
        cidr_block = "10.0.5.0/24"
        availability_zone = "us-east-1b"
      }
      db-az1 = {
        name = "db-az1"
        cidr_block = "10.0.6.0/24"
        availability_zone = "us-east-1a"
      }
      db-az2 = {
        name       = "db-az2"
        cidr_block = "10.0.7.0/24"
        availability_zone = "us-east-1b"
      }
    }
  }
}


## creating the docdb source across two db route tables using database cluster
docdb = {
  main = {
    engine                  = "docdb"
    engine_version          = "4.0.0"
    backup_retention_period = 2
    preferred_backup_window = "07:00-09:00"
    skip_final_snapshot     = true
    no_of_instances         = 1
    instance_class          = "db.t3.medium"
    allow_subnets           = "app"
  }
}


## creating the rds source across two db route tables using aurora-mysql db cluster
rds = {
  main = {
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.1"
    backup_retention_period = 1
    preferred_backup_window = "07:00-09:00"
    no_of_instances         = 1
    skip_final_snapshot     = true
    instance_class          = "db.t3.small"
    allow_subnets           = "app"
  }
}


## Elastic-Cache is a aws web service that makes it easy to set-up, manage and scale a distributed cache env in cloud
## This is also used across two db route tables using cluster
elasticache = {
  main = {
    engine = "redis"
    engine_version = "6.x"
    num_cache_nodes = 1
    node_type = "cache.t3.micro"
    allow_subnets  = "app"
  }
}

## Rabbitmq DB is created in a single node using db but not db cluster.

rabbitmq = {
  main = {
    instance_type = "t3.small"
    allow_subnets = "app"
  }
}


## Application Load-Balancers across two availability zones
alb = {
  public = {
    subnet_name = "public"
    name        = "public"
    internal    = false
    load_balancer_type = "application"
    allow_cidr  = ["0.0.0.0/0"]
  }
  private = {
    subnet_name = "app"
    name        = "private"
    internal    = true
    load_balancer_type        = "application"
    allow_cidr = ["10.0.2.0/24","10.0.3.0/24","10.0.4.0/24","10.0.5.0/24"]
  }
}

app = {
  catalogue = {
    component = "catalogue"
    instance_type = "t3.medium"
    desired_capacity   = 1
    max_size           = 4
    min_size           = 1
    subnet_name        = "app"
    port               = 8080
    allow_app_to       = "app"
    alb                = "private"
    listener_priority  = 10
    parameters         = ["docdb"]
  }

  cart = {
    component        = "cart"
    instance_type    = "t3.micro"
    desired_capacity = 1
    max_size         = 4
    min_size         = 1
    subnet_name      = "app"
    port               = 8080
    allow_app_to       = "app"
    alb                = "private"
    listener_priority  = 11
    parameters         = ["elasticache"]
  }

  user = {
    component        = "user"
    instance_type    = "t3.micro"
    desired_capacity = 1
    max_size         = 4
    min_size         = 1
    subnet_name      = "app"
    port               = 8080
    allow_app_to       = "app"
    alb                = "private"
    listener_priority  = 12
    parameters         = [ "docdb", "elasticache"]
  }

  shipping = {
    component        = "shipping"
    instance_type    = "t3.medium"
    desired_capacity = 1
    max_size         = 4
    min_size         = 1
    subnet_name      = "app"
    port               = 8080
    allow_app_to       = "app"
    alb                = "private"
    listener_priority  = 13
    parameters         = ["rds"]

  }

  payment = {
    component        = "payment"
    instance_type    = "t3.micro"
    desired_capacity = 1
    max_size         = 4
    min_size         = 1
    subnet_name      = "app"
    port               = 8080
    allow_app_to       = "app"
    alb                = "private"
    listener_priority  = 14
    parameters         = ["rabbitmq"]

  }

  frontend = {
    component        = "frontend"
    instance_type    = "t3.medium"
    desired_capacity = 1
    max_size         = 4
    min_size         = 1
    subnet_name      = "web"
    port             = 80
    allow_app_to     = "public"
    alb              = "public"
    listener_priority  = 10
    parameters         = []

  }
}




