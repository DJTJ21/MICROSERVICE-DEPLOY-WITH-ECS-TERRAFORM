output "vote_url" {
  description = "URL of the VOTE service"
  value       =  module.vote.vote_url
}

output "database_endpoint" {
  description = "Endpoint of the database"
  value       = module.database.db_endpoint
}

output "result_url" {
  description   = "URL of the RESULT service"
  value         = module.result.result_url
}