# Set the project as the default for the provider
provider "google" {
project = SE-EMEA-SANDBOX
}

# Create 10 storage buckets 
resource "google_storage_bucket" "bucket" {
count = 10
name  = "kasten-hol-student-${count.index}"
storage_class = "standard"
location      = "europe-west2"
force_destroy = true
uniform_bucket_level_access = true
lifecycle_rule {
  condition {
    age = 7
  }
  action {
    type = "Delete"
  }
}
}
