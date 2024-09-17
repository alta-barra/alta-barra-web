variable "deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Window in days to hold a key after deletion"
}

variable "namespace" {
  type = string
}
