cidr = "192.168.0.0/16"

enable_dns_hostnames = true
enable_dns_support   = true

vpc_name  = "tcw_vpc"
igw_tag   = "tcw_igw"

public_subnets_cidr_1  = "192.168.1.0/24"
public_subnet_tag_1    = "tcw_public_subnet_az_1a"

public_subnets_cidr_2  = "192.168.2.0/24"
public_subnet_tag_2    = "tcw_public_subnet_az_1b"

database_subnets_cidr_1 = "192.168.5.0/24"
database_subnet_tag_1   = "tcw_database_subnet_az_1a"

private_subnets_cidr_1  = "192.168.6.0/24"
private_subnet_tag_1    = "tcw_private_subnet_az_1b"

map_public_ip_on_launch = true

public_route_table_tag   = "tcw_public_route_table"
database_route_table_tag = "tcw_database_route_table"
private_route_table_tag  = "tcw_private_route_table"


