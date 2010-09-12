class PlotValidationError < StandardError; end

class CodeBuffer
  def initialize
    @text = ""
  end

  def <<(string)
    @text += "#{string}\n"
  end

  def to_s
    @text
  end
end

class RPlot

  OUTPUT_PATH = File.join(Dir.tmpdir, 'simulation_rplot_out.pdf')
  PLOT_PATH = File.join(Dir.tmpdir, 'simulation_rplot.R')

  def initialize file, y_axis, vary
    @result_file = file 

    @x_axis = vary.select{|q, v| v == :x_axis}.only.first
    @y_axis = y_axis.select{|q, b| b}.only.first
    unless vary.select{|q,v| v == :lines }.empty?
      @group = vary.select{|q,v| v == :lines}.only.first
    end
    @subplot = vary.select{|q,v| v == :subplot}.map(&:first)
    @subset_keys = vary.select{|q,v| v == :split}.map(&:first)
  end

  def pdf_file
    rpath = UserConfig.instance.R_path
    `#{rpath} <#{plot_file.path} --no-save`
    File.open(OUTPUT_PATH)
  end

  def plot_file
    File.open(PLOT_PATH, 'wb') { |f| f.write plot_code }
    File.open(PLOT_PATH)
  end

  private
  def plot_code
    code = CodeBuffer.new
    code << "library(lattice)"
    code << "trellis.device(device='pdf', file='#{OUTPUT_PATH}', paper='a4')"
    code << ""
    code << "plot_data <- read.csv('#@result_file')"
    code << ""

    subsets.each do |subset|
      xyplot(code,
        subset.join('==', ' & '),
	subset.join('=', ', ')
      )
    end
    xyplot(code) if subsets.empty?

    code.to_s
  end

  def xyplot code, subset_expression = '', sub = ''
     subset_expression = 'TRUE' if subset_expression == '' || subset_expression.nil?
     axes = "#@y_axis ~ #@x_axis"
     splots =  @subplot.empty? ? "" : "| " + @subplot.map{|q| "factor(#{q})"}.join(' + ') 
     group_expr = ""
     group_expr = "group = factor(#@group)" if @group
     code << "xyplot(#{axes} #{splots}, data = plot_data, type='l', auto.key = list(space = 'top', lines=TRUE), sub='#{sub}',"
     code << "subset = #{subset_expression}, #{group_expr})"
     code << ""
   end
   
  def subsets
    if @subsets.nil?
      subset_hash = {}
      fd = file_data
      @subset_keys.each do |k|
      	subset_hash[k] = fd[k].uniq.map do |v|
	  if v =~ /[0-9]*\.[0-9]+/ or v =~ /[0-9]+/
	    v
	  else
	    "'#{v}'"
	  end
	end
      end
      subset_hash.enable_multiple_parameters!
      @subsets = subset_hash.mutated
    end
    @subsets
  end

  def file_data
    FasterCSV.read(@result_file).transpose.to_h
  end
end
