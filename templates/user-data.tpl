#cloud-config

packages:
  - httpd

runcmd:
  - /bin/systemctl daemon-reload
  - /bin/systemctl enable httpd.service
  - /bin/systemctl start --no-block httpd.service
