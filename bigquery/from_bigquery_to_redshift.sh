GOOGLE_APPLICATION_CREDENTIALS=/var/www/html/data-management-platform/service_account.json GOOGLE_CLOUD_PROJECT=lmn-martech-dashb-affiliation bq extract --destination_format=CSV affiliation.costs_and_margins gs://affiliation-data/bigquery.csv && gsutil cp gs://affiliation-data/bigquery.csv /var/www/html/data-management-platform/bigquery/ && /home/web-user/.embulk/bin/embulk run /var/www/html/data-management-platform/bigquery/bigquery.yml
