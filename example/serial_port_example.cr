require "../src/serial_com_port.cr"

module SP
  extend self
  @@name = ""
  @@sp = uninitialized SerialComPort
  @@rx_buf = Bytes.new(255)

  def start(name)
    @@name = name
    while true
      begin
        @@sp = SerialComPort.new(@@name, SerialComPort::B115200)
      rescue ex
        puts ex
        sleep 1
        next
      end
      break
    end
    start_receiver
  end

  def stop
    begin
      @@sp.close
    rescue ex
      puts ex
    end
  end

  def restart
    stop
    start(@@name)
  end

  def start_receiver
    puts "start receive fiber"
    spawn do
      while true
        begin
          s = @@sp.read(@@rx_buf)
          puts "Rx: #{String.new(@@rx_buf)}"
          @@rx_buf = Bytes.new(255)
        rescue ex
          puts "receiver #{ex.message}"
          break
        end
      end
      puts "Receiver fiber Exit."
    end
    puts "start_receiver fiber done"
  end

  def send(data : Bytes)
    @@sp.write(data)
  end
end

#main loop
puts "Serial Port Test"
started = false
loop do
  str = gets.to_s

  if (str.starts_with?("stop:"))
    puts "Called Stop"
    SP.stop
    started = false
    next
  elsif (str.starts_with?("start:"))
    puts "Called Start"
    SP.start(str.gsub("start:",""))
    started = true
    next
  elsif (str.starts_with?("exit:"))
    puts "Called Exit"
    exit 0
  end

  if( started )
    puts "Sending #{str}"
    SP.send str.to_slice
  end
end
