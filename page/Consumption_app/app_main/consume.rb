require_relative 'consumption_app'

# todo: config for app
# ie: logger
# formatter.. html, account_object_file.. like the input file
#
flow_files_path
accounts_files_path

app = ConsumptionApp.new flow_files_path, accounts_files_path
