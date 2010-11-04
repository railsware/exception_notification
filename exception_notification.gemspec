Gem::Specification.new do |s|
  s.name = 'exception_notification_rails3'
  s.version = '1.2.0'
  s.authors = ["Jamis Buck", "Josh Peek"]
  s.date = Time.now.strftime("%F")
  s.summary = "Exception notification by email for Rails 3 apps"
  s.email = "timocratic@gmail.com"
  s.homepage = "http://github.com/railsware/exception_notification"

  s.files = ['README'] + Dir['lib/**/*']
  s.require_path = 'lib'
end
