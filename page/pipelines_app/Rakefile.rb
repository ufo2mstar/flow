# For the Mechanics who wanna service this Engine! :)
# $verbose_mode = true # uncomment for better init logs.. ie: proper cranking
# --------------------------------------------------
#
# require_relative 'your_configs/env_vrbls.rb'
# require 'cucumber/rake/task'
# draw_start_line
#
# name                = "#{ENV['user']||ENV['USER']||ENV['User']}_envs.yml"
# your_env_is_defined = File.exists?(name)
#
# desc "renames current output folder to make way for a new one!"
# task :flush do
#   init_envs({}, 'make no output')
#   flush_output
# end
#
# desc "env_maker! makes you \#{nw_short_id}_envs.yml"
# task :env do
#   ans = true
#   if your_env_is_defined
#     p "Wanna replace your #{name}? [yN]:"; ans = Kernel.gets =~ /y/i
#     (mv(name, name.gsub('.yml', Time.now.strftime("_%H-%M-%S.yml")), {verbose: false}); p("a new", :g)) if ans
#   end
#   if ans
#     cp Dir[File.dirname(__FILE__)+"/*conf*/env_vrbls.yml"].first, name, {verbose: false}
#     p name, :c
#     p "Successfully instantiated!\n  goforth on your Noble NOBEL QUEST my friend!!\n ", :g
#   end
# end

namespace :run do

  desc "can give inputs like => run:env[states:ar.ga.ms|verbose:y| kod: kk |user:sivasn1]"
  task :env, [:env] do |t, args|
    env_hash = parse_to_env args[:env]
    init_envs env_hash
    ( n = (ENV['times'].to_i if ENV['times']) || 1).times {|i| (p "RunCount : #{i+1}/#{n}",:y; $html_txt = "_#{'%02d' % (i+1)}in#{'%02d' % n}")if n != 1
    TaskSetup.build_all_tasks
    Cuke.list_run
    }
  end

  desc "Open diff threads with all the tasks.. \n threading States and Browsers for now"
  task :threads, [:env] do |t, args|
    init_envs parse_to_env args[:env]
    TaskSetup.build_all_tasks
    Cuke.thread_run
  end

  desc "Run the same thing over and over again! ENV['times'].to_i times..."
  task :many, [:env] do |t, args|
    init_envs parse_to_env args[:env]
    ENV['times'].to_i.times{
    Cuke.thread_run
    }
  end
end

# todo regression tasks
# namespace :ebi do
#   task :val do
#     # ebidb = EBIDatabase.new
#     # pass  = ebidb.runEBI
#     # raise DBValidationError, "EBI Fail!" unless pass
#   end
# end

namespace :uat_reg do

  task :no_db do
  end
  task :env, [:env] do |t, args|
    p ENV['user']
    p args[:env]
    p ENV['kk']
  end

  task :db do
    p ENV['user']
    p ENV['kk']
  end

end

require 'yard'
require 'yard-cucumber'

YARD::Rake::YardocTask.new do |t|
# # t.files   = ['../../**/*.feature', 'features/**/*.rb']
t.files   = ['../../**/*.feature']
#   t.files   = ['../**/*.rb']   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
  # t.stats_options = ['--list-undoc']         # optional
end


# Rake::Task['env'].invoke unless your_env_is_defined

desc "Runs 'rake env'.."
task :default => 'env'

# at_exit {
#   #todo: try_and_try
#   begin
#     wipe_htmls
#   rescue Exception => e
#     p ''
#     p "Skipping 'wipe_htmls'", :r # coz i don wanna do this for all processes..
#     # p "#{e}"
#   end
#   delete_cache rescue p "Skipping 'delete_cache'", :r # just for task runs is enough..
#   (pr "\n  oh.. and btw,", :m) if (rand > 0.5); p "\n..#{get_in_the_game}..", :cy; draw_ended_line }
# # todo.. woow woow.. benchmark n analyze rand patterns.. study the distrib
#
