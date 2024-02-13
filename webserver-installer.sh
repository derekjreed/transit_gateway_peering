#!/bin/bash
sudo mkdir /tmp/http_server
cd /tmp/http_server
python3 -m pip install httpserver
cat <<EOF >/tmp/http_server/test.html
<!doctype html>
<html>
  <head>
    <title>This is a TEST PAGE!</title>
  </head>
  <body>
    <p>This shows that <strong>body</strong> the Transit Gateway Peering <strong>p</strong> works as expected.</p>
  </body>
</html>
EOF
nohup /home/ssm-user/.local/bin/httpserver -a $(hostname -I) -p 3333 -h $(hostname -f) /tmp/http_server/ &
