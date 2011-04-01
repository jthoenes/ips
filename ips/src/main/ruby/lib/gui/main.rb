Rubeus::Swing.irb

javax.swing.UIManager.set_look_and_feel(javax.swing.UIManager.system_look_and_feel_class_name)


def information_message title, message
  Thread.new do
    javax.swing.JOptionPane.showMessageDialog(nil, message, title, javax.swing.JOptionPane::INFORMATION_MESSAGE)
  end
end

def do_time_profile frm, def_file
  task_in_background(frm) do
    runs = 100
    simulation_time = nil
    multiply = 0
    Reporting::Config.instance.silence
    loop do
      load_simulation_file def_file
      sim_config = Sim::Config.instance

      multiply = sim_config.runs.to_f/runs
      sim_config.runs = runs

      simulation_start = Time.now
      run_simulation
      simulation_time = Duration.new Time.now - simulation_start

      break if simulation_time.minutes > 1
      break if simulation_time.seconds > 1
      unless simulation_time.to_i == 0
        runs = ((runs.to_f/simulation_time.to_i)*80).to_i
      else
        runs *= 10
      end
    end
    Reporting::Config.instance.unsilence

    message = "For #{runs} Runs it took: #{simulation_time}\n"
    message += "Estimate time for #{(runs*multiply).to_i} Runs: #{Duration.new(simulation_time.to_i * multiply)}"

    information_message("Time-Estimate", message)
  end

end

def do_run frm, def_file
  task_in_background(frm) do
    load_simulation_file def_file
    run_simulation

    information_message("SUCCESS", "Simulation finished")
  end
end

def do_quick_run frm, def_file, runs
  task_in_background(frm) do
    load_simulation_file def_file
    Sim::Config.instance.runs = runs
    run_simulation

    information_message("SUCCESS", "Simulation finished")
  end
end

def task_in_background frm
  popup = javax.swing.JDialog.new
  begin
    frm.enabled = false

    t = Thread.new do
      progress_bar = javax.swing.JProgressBar.new
      progress_bar.indeterminate = true


      popup.title = "Simulation Running"
      popup.modal = true
      popup.content_pane.add progress_bar
      popup.default_close_operation= javax.swing.JDialog::DO_NOTHING_ON_CLOSE
      popup.set_size(800, 20)
      popup.pack
      popup.set_location_relative_to(frm)
      popup.visible = true
    end

    yield

    # Hide progress bar
  ensure
    popup.visible= false
    frm.enabled=true
  end
end

def show_plot_settings_panel(file, settings_panel)
  load_simulation_file(file.path)
  plot = $plot_model

  result_file = nil
  result_file = plot.result_file if File.exists?(plot.result_file)

  y_axis = {}
  y_axis[plot.y_axis_options.first] = true
  plot.y_axis_options.tail.each { |o| y_axis[o] = false }

  vary = {}
  vary[plot.vary_options.first] = :x_axis
  plot.vary_options.tail.each { |o| vary[o] = :ignore }

  settings_panel.viewportView = JPanel.new do |sp|
    sp.layout = BoxLayout.new(:Y_AXIS)
    JPanel.new do |p|
      p.layout = BoxLayout.new(:X_AXIS)
      JLabel.new "Result File"
      tf = JTextField.new(plot.result_file, :editable => false)

      wb = JButton.new(ImageIcon.new "misc/icons/delete.png")
      if result_file.nil?
        wb.toolTipText = 'Result File does not exist'
      else
        wb.enabled = false
      end


      JButton.new("Change ...") do
        ch = javax.swing.JFileChooser.new
        ch.fileFilter = javax.swing.filechooser.FileNameExtensionFilter.new("CSV Files", ["csv"].to_java(:string))
        if ch.show_open_dialog(nil) == javax.swing.JFileChooser::APPROVE_OPTION
          tf.text = ch.selected_file.path
          wb.enabled = false
          result_file = ch.selected_file
        end
      end
    end
    JPanel.new do |p|
      p.layout = BoxLayout.new(:X_AXIS)
      JLabel.new "Y-Axis"
      group = ButtonGroup.new
      y_axis.each do |option, selected|
        rbtn = JRadioButton.new(option, selected) # do
        group.add rbtn
        rbtn.add_action_listener do
          y_axis.each_key { |o| y_axis[o] = false }
          y_axis[option] = true
        end
      end
    end
    JPanel.new do |p|
      p.layout = BoxLayout.new(:Y_AXIS)
      vary.each do |option, type|
        JPanel.new do |op|
          op.layout = BoxLayout.new(:X_AXIS)
          JLabel.new(option)
          group = ButtonGroup.new
          rbtn = JRadioButton.new('X-Axis', type == :x_axis, :tool_tip_text => 'Draw this quantity as x-Axis.')
          rbtn.add_action_listener { vary[option] = :x_axis }
          group.add rbtn
          rbtn = JRadioButton.new('Lines', type == :lines, :tool_tip_text => 'Draw this quantity in different lines.')
          rbtn.add_action_listener { vary[option] = :lines }
          group.add rbtn
          rbtn = JRadioButton.new('Subplot', type == :subplot, :tool_tip_text => 'Draw this quantity in different subplots on one page.')
          rbtn.add_action_listener { vary[option] = :subplot }
          group.add rbtn
          rbtn = JRadioButton.new('Split', type == :split, :tool_tip_text => 'Split this quantity to different pages.')
          rbtn.add_action_listener { vary[option] = :split }
          group.add rbtn
          rbtn = JRadioButton.new('Ignore', type == :ignore, :tool_tip_text => 'Ignore this quantity.')
          rbtn.add_action_listener { vary[option] = :ignore }
          group.add rbtn
        end
      end
    end

    JPanel.new do
      JButton.new "Create Plot" do
        r_plot = RPlot.new(result_file, y_axis, vary)

        #jfile = java.io.File.new r_plot.pdf_file.path
        #jdesktop = java.awt.Desktop.getDesktop()
        #jdesktop.open jfile

        # Saving the R File
        ####
        ch = javax.swing.JFileChooser.new(File.dirname(Reporting::Config.instance.create_filename('R')))
        ch.fileFilter = javax.swing.filechooser.FileNameExtensionFilter.new("R Files", ["R"].to_java(:string))
        if ch.show_save_dialog(nil) == javax.swing.JFileChooser::APPROVE_OPTION
          File.open(ch.selected_file.path, 'wb') do |f|
            f.write r_plot.plot_file.read
          end
          information_message("SAVED!", "File saved")
        end
        ####
      end
    end
  end
end

JFrame.new("Internal Pilot Simulation") do |frm|
  frm.layout = BoxLayout.new(:Y_AXIS)
  frm.size = [800, 600]
  JTabbedPane.new do |tab|
    JPanel.new() do |mp|
      def_file = nil
      option = :run
      mp.layout = BoxLayout.new :Y_AXIS
      JPanel.new do |p|
        p.layout = BoxLayout.new(:X_AXIS)
        JLabel.new "Definition File"
        tf = JTextField.new("Chose File ...", :editable => false)

        JButton.new("Choose ..") do
          ch = javax.swing.JFileChooser.new
          ch.fileFilter = javax.swing.filechooser.FileNameExtensionFilter.new("Ruby Files", ["rb"].to_java(:string))
          if ch.show_open_dialog(frm) == javax.swing.JFileChooser::APPROVE_OPTION
            tf.text = ch.selected_file.path
            def_file = ch.selected_file.path
          end
        end
      end
      JPanel.new do |p|
        @run_field = nil
        p.layout = BoxLayout.new(:X_AXIS)
        JLabel.new "Run Mode"
        group = ButtonGroup.new
        rbtn = JRadioButton.new('Time-Estimate', false, :tool_tip_text => 'Estimate the time to run.')
        rbtn.add_action_listener { option = :time_profile; @run_field.enabled = false }
        group.add rbtn
        rbtn = JRadioButton.new('Run', true, :tool_tip_text => 'Run the simulation')
        rbtn.add_action_listener { option = :run; @run_field.enabled = false }
        group.add rbtn
        rbtn = JRadioButton.new('Quick-Run', false, :tool_tip_text => 'Run the simulation with specified runs.')
        rbtn.add_action_listener { option = :quick_run; @run_field.enabled = true }
        group.add rbtn
        @run_field = JTextField.new("500", :enabled => false)
      end
      JPanel.new do |p|
        JButton.new("Run!") do
          unless def_file.nil? and File.exists?(def_file)
            case option
              when :time_profile
                do_time_profile(frm, def_file)
              when :run
                do_run(frm, def_file)
              when :quick_run
                do_quick_run(frm, def_file, @run_field.text.to_i)
            end
          else
            javax.swing.JOptionPane.showMessageDialog(nil, "Please select a valid ruby file containing the simulation definition.", "Error",
                                                      javax.swing.JOptionPane::ERROR_MESSAGE)
          end
        end
      end
    end
    JSplitPane.new(JSplitPane::VERTICAL_SPLIT) do
      JPanel.new do |p|
        def_file = nil
        p.layout = BoxLayout.new(:X_AXIS)
        JLabel.new "Definition File"
        tf = JTextField.new("Chose File ...", :editable => false)

        JButton.new("Choose ..") do
          ch = javax.swing.JFileChooser.new
          ch.fileFilter = javax.swing.filechooser.FileNameExtensionFilter.new("Ruby Files", ["rb"].to_java(:string))
          if ch.show_open_dialog(frm) == javax.swing.JFileChooser::APPROVE_OPTION
            tf.text = ch.selected_file.path
            def_file = ch.selected_file
          end
        end
        JButton.new("Load") do
          if def_file.nil?
            javax.swing.JOptionPane.showMessageDialog(frm, "Please select a valid ruby file containing the simulation definition.", "Error",
                                                      javax.swing.JOptionPane::ERROR_MESSAGE)
          else
            show_plot_settings_panel(def_file, @settings_panel)
          end
        end
      end
      @settings_panel = JScrollPane.new
    end
    tab.set_title_at 0, "Perform Simulations"
    tab.set_title_at 1, "Plot Results"
  end
  frm.visible = true
end
