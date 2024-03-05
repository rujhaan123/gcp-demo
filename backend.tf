terraform {
 backend "gcs" {
   bucket  = "rb_testbuck123"
   prefix  = "terraform/state"
 }
}
