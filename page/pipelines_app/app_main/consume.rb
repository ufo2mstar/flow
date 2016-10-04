# A configuration driven flow creation app!
# todo: need to rake the whole thing up!!.. but am saving it until the development is done!
require_relative 'pipelines_app'

# todo: config for app
# ie: logger
# formatter.. html, account_object_file.. like the input file
#
flow_files_path = Dir.glob './config/flows'
accounts_files_path = Dir.glob './config/accounts'

app = ConsumptionApp.new flow_files_path, accounts_files_path
app.consume!