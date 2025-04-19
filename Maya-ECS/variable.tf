variable "container_port" {
    description = "The port number to be used"
    type        = number
    default     = 5000
}
variable "image" {
    description = "The Docker image to be used"
    type        = string
}
variable "aws_access_key" {
    description = "AWS Access Key"
    type        = string
}
variable "aws_secret_key" {
    description = "AWS Secret Key"
    type        = string
}