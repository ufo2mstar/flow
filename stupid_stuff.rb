# TIMING (to help Profiling)
# Thanks MatLab! :)
def tic
  $tic=Time.now
  print "TIC initiated -->\n"
end

def toc
  $toc=Time.now
  print "Elapsed time : #{$toc-$tic}\n"
  p $toc-$tic #watch out
end

def yp(obj)
  print obj.to_yaml
end

def yaml_load io
  YAML.load(io.gsub("=>", ": "))
end

class String
  def squash
    self.gsub(/\s+/, " ")
  end

  def trim
    self.gsub('_', ' ').strip
  end

  def titilecase
    self.trim.split(' ').map { |w| w.capitalize }.join(' ')
  end

  def camelcase
    self.trim.downcase.titilecase.gsub(/\s+/, '')
  end

  def snakecase
    self.trim.gsub(' ', '_').downcase
  end

  alias_method :downsnakecase, :snakecase

  def upsnakecase
    self.trim.gsub(' ', '_').upcase
  end
end