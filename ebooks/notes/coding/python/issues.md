## SSLError: [Errno 8] _ssl.c:504: EOF occurred in violation of protocol

> There was a problem confirming the ssl certificate: [SSL: TLSV1_ALERT_PROTOCOL_VERSION] tlsv1 alert protocol version

**Fix in Max OSX**
```sh
brew install libffi
curl https://bootstrap.pypa.io/get-pip.py | python
pip install -U requests[security]
```

**Fix in Linux**
```sh
sudo apt-get install libffi-dev
sudo pip install -U requests[security]
```
