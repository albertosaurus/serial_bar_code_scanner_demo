require 'java'

directory = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'java')

Dir.entries(directory).each do |file|
  if file.end_with?(".jar")
    require "#{directory}/#{file}"
  end
end
