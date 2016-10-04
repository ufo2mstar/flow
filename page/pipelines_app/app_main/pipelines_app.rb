require_relative 'molecule_render' # not so general purpose right now.. will get there.. object_render was too vauge!
require_relative 'flow_render'

class PipelinesApp
  attr_accessor :molecules, :flows

  def initialize flow_files_path, molecules_files_path
    # object-ifiers
    @flow_renderer = new FlowRender flow_files_path
    @accunt_renderer = new moleculeRender molecules_files_path

    # collections (string arrays)
    @flows = []
    @molecules = []
    @queues = []

    # for internal use only:
    @@molecule_params = {}

  end

  def init_molecules *molecule_hash_ary
    molecule_hash_ary.each do |molecule_hash|
      molecule_name = molecule_hash.keys.first # string
      molecule_params = @accunt_renderer.objectify molecule_hash.values.first #hash
      @molecules << molecule_name
    end
  end

  def consume! flow_path # , molecules??
# todo: execute the flow here!.. molecules and properties are assigned at this level
  end

  private
  def setup_molecule_obj molecule_name, prop_hsh
    self.send(molecule_name)
  end

end
