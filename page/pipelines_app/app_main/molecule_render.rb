

class MoleculeRender
  # for initialising all molecule and tying them to their params
  # all getting and setting can be done through this layer
  def initialize
    @prop_hsh = {}
  end

  def init_molecule name_str, properties_hsh
    # return internal class that conforms to
    # i.e: return getter and setters for property on saying acc_obj.prop and acc_obj.prop=
  end

  def objectify
    #todo: for setup logic.. use assign_props
  end

  protected

  # reflective hash that is
  # - query-able for storing the property values and
  # - gives the property back (by name) for assignment..
  def assign_prop
    @prop_hsh # todo: hmm.. need to think.. should we internal class this?
  end

  def get_prop
    # not sure we need this
  end
end
