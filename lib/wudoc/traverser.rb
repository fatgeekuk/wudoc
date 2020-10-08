require 'json'

class Wudoc::Traverser
  def initialize config, base
    @config = config
    @base = base
  end

  def location
    @config.location
  end

  def scan
    Dir.glob(file_pattern) do |line|
      relative = line.gsub(location + '/', '')
      if ignore_list.include?(relative)
        # puts "ignoring #{ relative }"
      else
        if File.directory?(line)
          @base.throw_traverser_on_queue self.class.new(@config.descend(relative), @base)
        else
          document line, relative
        end
      end
    end
  end

  def document file_path, file_name
    documenter_class = @base.documenter_for(file_name)
    unless documenter_class.nil?
      d = documenter_class.new(@base, file_path, @config.descend(file_name))
      d.process
    end
  end

  private

  def ignore_list
    @config.ignore_list || []
  end

  def file_pattern
    [location, '*'].compact.join('/')
  end
end
