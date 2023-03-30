require "termios"
require "./serial_com_port/version.cr"

@[Link(ldflags: "#{__DIR__}/serial_libc.o")]
lib SerialLibC
  fun serial_init(fd : LibC::Int, baud_rate : LibC::Int) : LibC::Int
end

class SerialComPort < IO
  B0       = 0      
  B50      = 50     
  B75      = 75     
  B110     = 110    
  B134     = 134    
  B150     = 150    
  B200     = 200    
  B300     = 300    
  B600     = 600    
  B1200    = 1200   
  B1800    = 1800   
  B2400    = 2400   
  B4800    = 4800   
  B9600    = 9600   
  B19200   = 19200  
  B38400   = 38400  
  B57600   = 57600  
  B115200  = 115200 
  B230400  = 230400 
  B460800  = 460800 
  B500000  = 500000 
  B576000  = 576000 
  B921600  = 921600 
  B1000000 = 1000000
  B1152000 = 1152000
  B1500000 = 1500000
  B2000000 = 2000000
  B2500000 = 2500000
  B3000000 = 3000000
  B3500000 = 3500000
  B4000000 = 4000000
  B4500000 = 4500000
  B5000000 = 5000000

  def initialize(ttyName : String, baud_rate = B9600, buffer_size = 1024)
    @sp_name = ttyName
    @sp = File.open(@sp_name, "r+")
    @buffer_size = buffer_size
    # Disable buffers
    @sp.read_buffering = false
    @sp.sync = true
    @sp.flush_on_newline = false
    # Set specific serial port settings
    @sp.flock_exclusive
    @sp.raw!
    #pp! @sp.blocking
    @sp.blocking=false
    #pp! @sp.read_timeout
    @sp.read_timeout = nil
    fd = @sp.fd
    SerialLibC.serial_init(fd, baud_rate)
    ::puts "Opened tty device: " + ttyName
  end

  # Forward IO relevant methods to @sp
  def close
    @sp.close
  end
  def closed?
    @sp.closed?
  end
  def flush
    @sp.flush
  end
  def read(slice : Bytes)
    @sp.read(slice)
  end
  def write(slice : Bytes) : Nil
    @sp.write(slice)
    @sp.flush
  end
  def send(slice : Bytes) : Nil
    write(slice)
  end
  def receive : Array(UInt8)
    byte_arr = Array(UInt8).new
    rbyte = Bytes.new(@buffer_size)
    begin
      num = read(rbyte.to_slice)
      if( num == 0 )
        raise "IO Error Read 0 bytes!"
        return byte_arr
      end
      rbyte.each_with_index do |c, i|
        if (i >= num)
          break
        end
        byte_arr << c
      end
    rescue ex
      raise ex
    end
    return byte_arr
  end
  def receive_slice : Bytes
    rbyte = Bytes.new(@buffer_size)
    begin
      num = read(rbyte.to_slice)
      if( num == 0 )
        raise "IO Error Read 0 bytes!"
        return rbyte
      end
    rescue ex
      raise ex
    end
    rbyte = rbyte[0..num-1]
    return rbyte
  end
end
