require 'torquebox-stomp'

class BarCodeScannerStomplet
  # Implements a serial port event listener
  class ScannerEventListener
    include Java::Jssc::SerialPortEventListener

    def initialize(stomplet)
      @stomplet = stomplet
    end

    java_signature 'void serialEvent(jssc.SerialPortEvent event)'
    def serialEvent(event)
      @stomplet.process_serial_port_event(event)
    end
  end
  
  def initialize
    @subscribers = []
    @mutex       = Mutex.new
  end

  def configure(config)
    com_port = '/dev/tty.usbmodem1421'
    if File.exists? com_port
      Rails.logger.debug "Opening serial port #{com_port}"
      @serial_port = Java::Jssc::SerialPort.new(com_port)
      @serial_port.openPort
      @serial_port.setParams(115200, 8, 1, 0)
      mask = Java::Jssc::SerialPort::MASK_RXCHAR +
        Java::Jssc::SerialPort::MASK_CTS +
        Java::Jssc::SerialPort::MASK_DSR
      @serial_port.setEventsMask(mask)
      @serial_port.addEventListener(::BarCodeScannerStomplet::ScannerEventListener.new(self))
    end
  end
  
  def destroy
    if @serial_port
      @mutex.synchronize {
        @serial_port.closePort
        @serial_port = nil
      }
    end
  end

  # Adds the given subscriber to the subscribers list (synchronized).
  def on_subscribe(subscriber)
    Rails.logger.debug "Subscribed #{subscriber}"
    @mutex.synchronize { @subscribers << subscriber }
  end

  # Removes the given subscriber from the subscribers list (synchronized).
  def on_unsubscribe(subscriber)
    Rails.logger.debug "Unsubscribed #{subscriber}"
    @mutex.synchronize{ @subscribers.delete( subscriber ) }
  end
  
  def process_serial_port_event(event)
    if event.isRXCHAR && event.getEventValue > 0
      begin
        buffer          = @serial_port.readBytes(event.getEventValue)
        message_string  = Java::JavaLang::String.new(buffer).to_s
        send_to_subscribers(message_string)
      rescue Exception => e
        Rails.logger.error "Failed to process bar code data: #{e}"
      end
    end
  end

  def send_to_subscribers(message_string)
    Rails.logger.debug "Sending to subscribers: #{message_string}"
    @mutex.synchronize do
      @subscribers.each do |sub|
        begin
          message = org.projectodd.stilts.stomp.DefaultStompMessage.new
          message.setContentAsString(message_string)
          Rails.logger.debug "Sending #{message_string} to #{sub}"
          sub.send(message)
        rescue Exception => e
          Rails.logger.error "Failed to send to subscriber #{sub}: #{e}"
        end
      end
    end # mutex.synchronize
  end
end