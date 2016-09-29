require_relative 'account_render' # not so general purpose right now.. will get there.. object_render was too vauge!
require_relative 'flow_render'

class ConsumptionApp
  attr_accessor :accounts, :flows

  def initialize flow_files_path, accounts_files_path
    # object-ifiers
    @flow_renderer = new FlowRender flow_files_path
    @accunt_renderer = new AccountRender accounts_files_path

    # collections (string arrays)
    @flows = []
    @accounts = []

    # for internal use only:
    @@account_params = {}

  end

  def init_accounts *account_hash_ary
    account_hash_ary.each do |account_hash|
      account_name = account_hash.keys.first # string
      account_params = @accunt_renderer.objectify account_hash.values.first #hash
      @accounts << account_name
    end
  end

  def consume! flow_path # , accounts??
# todo: execute the flow here!.. accounts and properties are assigned at this level
  end

  private
  def setup_account_obj account_name, prop_hsh
    self.send(account_name)
  end

end
