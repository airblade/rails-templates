#
# Delete unnecessary files.
#

run 'rm README'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/robots.txt'
run 'rm public/images/rails.png'
run 'rm -f public/javascripts/*'


#
# Get jQuery
#

run 'curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.js > public/javascripts/jquery.js'


#
# Gems
#

gem 'haml'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => 'http://gems.github.com'
if yes?('Do you need authorisation?')
  gem 'stffn-declarative_authorization', :lib => 'declarative_authorization'
end
if yes?('Do you need soft-deletion for your models?')
  gem 'jchupp-is_paranoid', :lib => 'is_paranoid', :source => 'http://gems.github.com'
end
rake 'gems:install', :sudo => true


# Initialise Git
git :init


# 
# Plugins
#

plugin 'css_dryer', :git => 'git://github.com/airblade/css_dryer.git', :submodule => true
generate :css_dryer
route "map.stylesheets 'stylesheets/:action.:format', :controller => 'stylesheets'"
run 'rm app/views/stylesheets/{test,_foo}.css.ncss'

plugin 'air_budd_form_builder', :git => 'git://github.com/airblade/air_budd_form_builder.git', :submodule => true
plugin 'air_blade_tools', :git => 'git://github.com/airblade/air_blade_tools.git', :submodule => true
if yes?('Do you need to upload files?')
  plugin 'paperclip', :git => 'git://github.com/airblade/paperclip.git', :submodule => true
end
if yes?('Do you need search?')
  plugin 'thinking-sphinx', :git => 'git://github.com/freelancing-god/thinking-sphinx.git', :submodule => true
end
if yes?('Do you need exception notification?')
  plugin 'exception_notification', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
  prefix = ask('What subject prefix do you want for exception notifications?')
  sender = ask('What sender address do you want for exception notifications?')
  initializer 'exception_notification.rb', <<-CODE
ExceptionNotifier.exception_recipients = %w( support@airbladesoftware.com )
ExceptionNotifier.email_prefix         = "[#{prefix}] "
ExceptionNotifier.sender_address       = "#{sender}"
CODE
  puts '** Now add "include ExceptionNotifiable" to ApplicationController. **'
  puts %(** Now add "consider_local 'xx.xx.xx.xx'" to ApplicationController. **)
end


#
# Initializers
#

# Date and time formats
initializer 'formats.rb', <<-'CODE'
formats = {
  # Friday 5th June 2009
  :full => lambda { |time|
    "#{time.strftime("%A")} #{time.day.ordinalize} #{time.strftime("%B %Y")}"
  },

  # 3:45pm
  :twelve_hour => lambda { |time| time.strftime('%l:%M') + time.strftime("%p").downcase }
}
Date::DATE_FORMATS.update formats
Time::DATE_FORMATS.update formats
CODE


#
# Git
#

git :submodule => 'init'

file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
db/*.sqlite3
END

run 'touch tmp/.gitignore log/.gitignore vendor/.gitignore'

git :add => '.', :commit => '-m "First commit."'
