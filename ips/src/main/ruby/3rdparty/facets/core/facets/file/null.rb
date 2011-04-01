class File

  # Platform dependent null device.
  #
  # CREDIT: Daniel Burger

  def self.null
    case Config::CONFIG['host_os']
      when /mswin|windows/i
        'NUL'
      when /amiga/i
        'NIL:'
      when /openvms/i
        'NL:'
      else
        '/dev/null'
    end
  end

end

