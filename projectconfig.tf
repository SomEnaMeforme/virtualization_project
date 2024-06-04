terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
 
provider "yandex" {
  token  =  "y0_AgAAAAByHjNtAATuwQAAAAD_BygDAABovdjQB1tINJiykBd3fbBRvxYpog"
  cloud_id  = "b1gbuh5m0kdc64mjs81e"
  folder_id = "b1g8t73n2l3ndbi4fjis"
  zone      = "ru-central1-a"
}

resource "yandex_serverless_container" "project-container" {
  name               = "rushkovaproject"
  memory             = 1024
  service_account_id = "aje7b4v33agc2qu6khne"
  image {
      url = "cr.yandex/crphjho4bagod91ai5ss/projectimagerushkova"
  }
}
 
resource "yandex_vpc_network" "network-1" {
  name = "projectnetwork"
}
 
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "project-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.131.0.0/16"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "project-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.132.0.0/16"]
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "project-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.133.0.0/16"]
}
 
resource "yandex_mdb_postgresql_cluster" "postgresqlprojectrushkova2" {
  name        = "postgresqlprojectrushkova2"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.network-1.id
 
  config {
    version = 15
    resources {
      resource_preset_id = "s3-c2-m8"
      disk_type_id       = "network-hhd"
      disk_size          = 10
    }
    postgresql_config = {
      max_connections                   = 395
      enable_parallel_hash              = true
      vacuum_cleanup_index_scale_factor = 0.2
      autovacuum_vacuum_scale_factor    = 0.34
      default_transaction_isolation     = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries          = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }

  maintenance_window {
    type = "ANYTIME"
  }
 
  database {
    name  = "db1"
    owner = "rushkova"
  }
 
  user {
    name       = "rushkova"
    password   = "12345678"
    conn_limit = 50
    permission {
      database_name = "db1"
    }
    settings = {
      default_transaction_isolation = "read committed"
      log_min_duration_statement    = 5000
    }
  }
 
  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet-1.id
    assign_public_ip = true
  }
  host {
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.subnet-2.id
    assign_public_ip = true
  }
  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.subnet-3.id
    assign_public_ip = true
  }
}