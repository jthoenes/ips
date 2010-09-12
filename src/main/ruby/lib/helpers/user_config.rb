class UserConfig < OpenStruct
  include Singleton
  
  INITIAL_CONFIG = {
    :email => { 
      :receiver => ['johannes.thoenes@googlemail.com'],
      :sender => 'johannes.thoenes@urz.uni-heidelberg.de',
      :server => 'extmail.urz.uni-heidelberg.de',
      :port => '25',
      :domain => 'urz.uni-heidelberg.de',
      :username => 'jthoenes',
      :password => '***********',
      :auth_method => :login
    },
    :R_path => 'C:\Programme\R\R-2.9.0\bin\R.exe'
  }.freeze
  
  CONFIGURATION_FILE = '.internal_pilot_simulator.yml'.freeze

  def initialize# Conf-File
    conf_filepath = File.join(homedir, CONFIGURATION_FILE)
    unless File.exists?(conf_filepath)
     File.open(config_path, 'w'){|f| f.write(YAML.dump(INITIAL_CONFIG))}
    end

    super(YAML.load_file(conf_filepath))
  end
  
  private
  def homedir
	Java::JavaLang::System.get_property 'user.home'
  end
end

