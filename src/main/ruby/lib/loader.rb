# Load files from dir
def require_folder path
	dir = File.join(File.dirname(__FILE__), path)
	if File.exists?(File.join(dir, 'loader.rb'))
		require File.join(dir, 'loader.rb')
	else
    Dir.glob(File.join(dir, '*.rb')).each {|f| puts f; require f}
	end
end

# Generate the URI path from a classpath file
def resource_uri path
  ClassPathResource.new(path).uri.to_s
end


# Require Java Support
require 'java'
include_class 'de.bergischweb.simulation.helper.JRubyHelper'
include_class 'org.springframework.core.io.ClassPathResource'

# Ruby Core Library
require 'ostruct'
require 'yaml'

# Gems
$:.unshift File.join(File.dirname(__FILE__), '../3rdparty/facets')
require 'duration'
$:.unshift File.join(File.dirname(__FILE__), '../3rdparty/i18n')
require 'i18n'
$:.unshift File.join(File.dirname(__FILE__), '../3rdparty/log4r')
require 'log4r'
$:.unshift File.join(File.dirname(__FILE__), '../3rdparty/fastercsv')
require 'fastercsv'

## Init JRuby helper
JRubyHelper.get_instance.init_ruby(Object.new)

## Translations
translation_backend = I18n::Backend::Simple.new
translation_backend.load_translations resource_uri('META-INF/i18n/en.yml')
I18n.backend = translation_backend

## Logger
require 'log4r/yamlconfigurator'
include Log4r
YamlConfigurator.load_yaml_file resource_uri('META-INF/log_config.yml')

## Modules
module Sim; end
module Reporting; end
module Distribution; end
module RNG; end

# Thread Configuration
Thread.abort_on_exception=true


## Loading files
# ./ext
require 'ext/numeric_ext'
require 'ext/array_ext'
require 'ext/faster_csv_ext'
require 'ext/fixnum_ext'
require 'ext/hash_ext'
require 'ext/range_ext'
require 'ext/assert_ext'
# ./helpers
require 'helpers/memoization'
require 'helpers/user_config'
require 'helpers/iteration_helper'

# ./test_strategies/helpers
require 'test_strategies/helpers/equivalence'
require 'test_strategies/helpers/extract_helper'
require 'test_strategies/helpers/hypothesis_dom'
require 'test_strategies/helpers/superiority'
require 'test_strategies/helpers/variables_struct'

# ./test_strategies
module TestStrategy; class Base; end;end
require 'test_strategies/base_iteration_approx'
require 'test_strategies/none'
require 'test_strategies/equivalence_dom'
require 'test_strategies/non_inferiority_dom'
require 'test_strategies/superiority_dom'
require 'test_strategies/pigeot_et_al'
require 'test_strategies/base'

# ./distributions
require 'distributions/base'
require 'distributions/gauss'
require 'distributions/student_t'

# ./rng
require 'rng/gauss.rb'

# ./reporting
require 'reporting/config'
require 'reporting/helpers/observer'
require 'reporting/helpers/observable'
require 'reporting/single_result'
require 'reporting/series_result'
require 'reporting/series_result_requirements'
require 'reporting/series_outputter'
require 'reporting/single_outputter'
require 'reporting/progress_observer'
require 'reporting/single_series_observer'
require 'reporting/single_observer'
require 'reporting/series_observer'
require 'reporting/mailer'

# ./sim
require 'sim/adjuster.rb'
require 'sim/data_array.rb'
require 'sim/instruction.rb'
require 'sim/instruction_pool.rb'
require 'sim/data.rb'
require 'sim/arm.rb'
require 'sim/config.rb'

# ./dsl_proxies/handlers
require 'dsl_proxies/handers/base'
require 'dsl_proxies/handers/boolean_handler'
require 'dsl_proxies/handers/symbol_handler'
require 'dsl_proxies/handers/range_handler'
require 'dsl_proxies/handers/numeric_handler'
require 'dsl_proxies/handers/quantity_handler'

# ./dsl_proxies/helpers
require 'dsl_proxies/helpers/multiple_parameters'
require 'dsl_proxies/helpers/distribution_helper'
require 'dsl_proxies/helpers/subproxy_helper'
require 'dsl_proxies/helpers/variables_helper'

# ./dsl_proxies
require 'dsl_proxies/base'
require 'dsl_proxies/test'
require 'dsl_proxies/sample_size'
require 'dsl_proxies/internal_pilot'
require 'dsl_proxies/arms'
require 'dsl_proxies/arms'
require 'dsl_proxies/series_collect'
require 'dsl_proxies/single_collect'
require 'dsl_proxies/collect'
require 'dsl_proxies/simulation'

# ./plot
require 'plot/plot_model'
require 'plot/r_plot'