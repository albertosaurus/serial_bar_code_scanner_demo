TorqueBox.configure do
  stomp do
    host 'localhost'
  end

  stomplet BarCodeScannerStomplet do
    route '/bar_code_scanner'
  end
end
