

module YamlRider
  def match_data file_name, file_data, raw_data_list
    matched_data = []; rejects =[]; res = []
    raw_data_list.reject! { |dat| a=file_data[dat]; (rejects << dat; matched_data << a) if a }
    # raise EmptyDataError, "Empty Data detected!!\n #{rejects}" if matched_data.empty? #todo not sure of use
    # raise MultipleDataError, "Multiple Data detected!!\n for #{rejects}\n #{matched_data}" if matched_data.size > 1
    matched_data.each { |data| res << parse(file_name, data) }
    res.inject(:merge)
  end

  def find_all *raw_data
    raw_default_data = raw_data.first
    raw_key_data     = raw_data.last
    key_res          =[]; def_res=@bucket_list
    file_list        = @base_inp_files+@base_state_inp_files
    (file_list).each do |file|
      file_name = get_file_name(file)
      file_data = erb_eval file
      def_res << match_data(file_name, file_data, raw_default_data) unless raw_default_data.empty?
      key_res << match_data(file_name, file_data, raw_key_data) unless raw_key_data.empty?
      break if raw_default_data.empty? and raw_key_data.empty?
    end
    # raise EmptyDataError, "Empty Data detected!!\n #{raw_fill_data}" if res.empty? #todo not sure of use
    d = def_res.compact.inject(:merge) || {}; k = key_res.compact.inject(:merge) || {}
    raise MissingDataError, "No Data detected for!!\nDef : #{raw_default_data}\nKey : #{raw_key_data}\n in -\n#{file_list.join "\n"}\nBut found -\nDef : #{d}\nKey : #{k}\n" unless raw_default_data.empty? and raw_key_data.empty?
    d.merge k
  end

  def get_key_ary_of val # 'key ; some str' -> ["KEY" , "SOME_STR"] .. or.. nil -> []
    #stripping here.. lets see when its not needed
    # return parse_to_a(val, ';').map { |a| a.strip.gsub(' ', '_').upcase } if val.class.to_s == "String"
    return parse_to_a(val, ';').map { |a| x=keyize(a.strip); x.empty? ? nil : x }.compact if val.class.to_s == "String"
    (val.compact if val) || []
  end

  def get_fill_data data_keys_ary
    fail "define [@state_inp_file | @common_inp_file | both] please" unless @state_inp_file or @common_inp_file
    common_data = erb_eval(@common_inp_file) rescue {}
    state_specific_data = erb_eval(@state_inp_file) rescue {}
    # todo: hope that we don't have any issues in this Bold (Stupid) change below
    base_state_data    = (@base_state_inp_files.map { |file| erb_eval(file).keys.map { |data_key| {data_key => data_key} } }).flatten.inject(:merge) || {}

    # Inheritance order:
    # state_specific_address_kinda_data -> common_data -> state_specific_data
    shallow_state_data = base_state_data.merge common_data
    state_data         = shallow_state_data.merge state_specific_data

    data_keys_ary.unshift "HAPPY_PATH_BUCKET" if wanna_run_bucket_list
    remnants = data_keys_ary.select { |x| x !~ /bucket/i }+["DEFAULT"]-state_data.keys
    raise(MissingKeyError, "\nDid not find '#{remnants}'\n in file\n#{@state_inp_file}\n\n") unless remnants.empty?

    key_vals               = key_bucket(data_keys_ary, state_data)
    def_vals               = state_data['DEFAULT']
    def_ary, key_ary       = [get_key_ary_of(def_vals), get_key_ary_of(key_vals)]
    @def_items, @key_items = def_ary.dup, key_ary.dup
    clean_def_ary          = def_ary
    clean_key_ary          = key_ary
    # Remove !ed keys from Default_array
    # Make sure you use quotes for the array strings ..
    # ie FILL_KEY: !DEFAULT_KEY1;KEY2   <-- Wrong!
    #    FILL_KEY: '!DEFAULT_KEY1;KEY2' <-- Right!!
    key_ary.each { |x| (clean_def_ary=clean_def_ary-[$1]; clean_key_ary=clean_key_ary-[x]) if x =~/^!(.*)/ }
    [clean_def_ary, clean_key_ary]
  end

  def get_serial file_name

  end

  def set_coverages_rands get_coverage_defaults = false
    rand_hsh   = {}
    cvgs_lists = self.methods.map { |cvg| cvg if cvg.to_s =~ /_COVERAGE_LIST$/i }.compact
    cvgs_lists.map { |cvg|
      begin
        list_name                 = elementify(cvg)
        list_vals                 = get_coverage_defaults ? [scrape_select_list_current_value(list_name)] : scrape_select_list_values(list_name)
        rand_hsh[cvg.to_s.upcase] = list_vals unless list_vals.empty?
      rescue Exception => e
        p("rescuing unfound #{list_name}\n coz #{e}", :y)
      end
    }
    dp rand_hsh if verbose_mode
    rand_hsh.each { |k, v|
      # # warn: this is a relic of the old way of doing coverages page..
      #   this has been improved upon currently.. and the below is just Dead Code..
      # but had some interesting logic in there that may be useful for later
      # Just to describe what it did..
      # todo: look to use the usual run.. just pretend the evaluation has happened before
      # if v.is_a? Hash # coverages specific block
      #   cvrg_element  = k; diff_cvrg_element = nil
      #   list_text_key = v.values[0]
      #   if list_text_key.is_a? Hash
      #     diff_cvrg_element = list_text_key.keys[0].strip
      #     list_text_key     = rand<0.8 ? list_text_key.values[0] : "" #  n% chance of selecting a non default coverage!
      #   end
      #   next if list_text_key.to_s.strip.empty?
      #   v = get_ary_of(get_validation_data("LISTS", list_text_key))
      #   # @bucket_list << {(diff_cvrg_element || "#{cvrg_element.strip}_COVERAGE_LIST") => (v[(@comb.to_i)-1] if @comb)|| v.sample}
      #   @bucket_list << {(diff_cvrg_element || "#{cvrg_element.strip}_COVERAGE_LIST") => (v[(@comb.to_i)-1] if @comb)|| v.seeded_sample}
      #   next
      # end
      if k.to_s =~ /_COVERAGE_LIST/i # better coverages specific block
        @bucket_list << {k => (v[(@comb.to_i)-1] if @comb)|| v.seeded_sample}
        next
      end
    }
    []
  end

  def get_rands file_name
    return [] unless file_name
    set_coverages_rands if special_page 'Coverage' # do different things for coverages page
    rand_hsh = erb_eval file_name
    res = []
    rand_hsh.each { |k, v|
      res << keyize(v.is_a?(Array) ? v.sample : v) unless k.to_s =~ /_COVERAGE_LIST/i # neglect _COVERAGE_LISTs coz they are handled in coverages_rands
    }
    res.flatten
  end

  def special_page rex_str
    self.class.to_s =~ /#{rex_str}/
  end

  # e2e Additions : --------------------------------------------
  def key_bucket keynames, state_data
    ret = ''
    # todo: think about supporting !KEY to remove stuff.. too deep and goes against the convention here though
    keynames.each { |keyname|
      res   = case keyname
        when /HAPPY_PATH_(\d+)/
          @comb = $1
          # get_serial @inp_happy_path_bucket
          get_rands @inp_happy_path_bucket
        when /HAPPY_PATH/
          get_rands @inp_happy_path_bucket
        when /HARDFALL/
          get_rands @inp_hardfall_bucket
        when /SOFTFALL/
          get_rands @inp_softfall_bucket
        when /NAMED/ #todo:
          get_rands @inp_named_bucket
        when /DEFAULT/ #todo:
          special_page('Coverage') ? set_coverages_rands('just_defaults') : []
        else
          [state_data[keyname]]
      end
      ret   += ';'+res.join(';')
      @comb = nil
    }
    p "Bucketing - #{ret[1..-1].gsub(/;/, ' , ')}#{ "and "+@bucket_list.map(&:keys).flatten.to_s unless @bucket_list.empty?}" if wanna_run_bucket_list
    ret
  end

  def get_keyz keys
    keys.to_s.split(',').map { |x| x.strip.keyize }
  end

  # another baker! ----------------------------------------------
  def bake_input_hsh keys
    tic 'fill'
    keynames                       = get_keyz keys
    raw_default_data, raw_key_data = get_fill_data keynames
    proper_fill_data               = find_all raw_default_data, raw_key_data
    dp proper_fill_data, "Preparing to Fill:", :c if verbose_mode
    keyname = keynames.join ','
    p "filling #{@page_name} with '#{keyname}'#{ " + 'DEFAULT'" if keyname != "DEFAULT"}", :m
    fill_order = erb_eval(@fillorder_file)
    @page_filled << {keyname => @key_items}; @page_filled << {"DEFAULT" => @def_items} if keyname != "DEFAULT"
    toc 'fill', "for baking the input"
    [proper_fill_data, fill_order["FILL_ORDER"]] # eve has it!
  end

end