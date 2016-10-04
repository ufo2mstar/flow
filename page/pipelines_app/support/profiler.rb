class Profiler
  include OutputFiler
  class<<self
    # require 'ruby-prof' if nav_profilin

    def start_profiling
      require 'ruby-prof' if profiling_mode
      p ">> starting ze Profiler!...", :gy
      RubyProf.start
    end

    def store_profiling
      p "<< storing ze Profiler!...", :gy
      @results = RubyProf.stop
      self.make_file("#{$scenario_folder}profile-table.html", "GraphHtmlPrinter")
      #--mode=memory and --printer=graph_html
      self.make_file "#{$scenario_folder}profile-tree.prof", "CallTreePrinter"
      self.make_file "#{$scenario_folder}profile-flat.txt", "FlatPrinter"
    end

    def make_file(file_name, class_name)
      eval("File.open(\"#{file_name}\", 'w'){|file| RubyProf::#{class_name}.new(@results).print(file)}")
    end
  end
  # private_class_method :make_file


end
