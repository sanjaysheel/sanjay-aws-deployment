variable "queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "fifo_queue" {
  description = "Indicates whether the queue should be FIFO"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "delay_seconds" {
  description = "The time in seconds to delay the visibility of the message"
  type        = number
  default     = 0
}

variable "maximum_message_size" {
  description = "The maximum message size (in bytes) that can be sent to the queue"
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "How long messages are retained in the queue"
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "The amount of time to wait before returning a message"
  type        = number
  default     = 0
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the queue"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to assign to the queue"
  type        = map(string)
  default     = {}
}
