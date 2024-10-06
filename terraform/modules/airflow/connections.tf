resource "null_resource" "airflow_connections" {
  provisioner "local-exec" {
    command = <<EOT
    curl -s -X POST "${var.airflow_api_url}/connections" \
      -u "${var.airflow_username}:${var.airflow_password}" \
      -H "Content-Type: application/json" \
      -d '{
            "conn_id": "${var.conn_id}",
            "conn_type": "${var.conn_type}",
            "host": "${var.pg_host}",
            "login": "${var.pg_user}",
            "password": "${var.pg_pass}",
            "port": 5432,
            "schema": "${var.pg_db}",
            "extra": ""
          }'
    EOT
   }
}