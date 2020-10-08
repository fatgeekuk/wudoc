require 'erb'

class Wudoc
  def initialize path
    @path            = path
    @base            = FileUtils.pwd
    @queue           = []
    @traverser_count = 0

    @config = Configuration.new(@base)

    @writer = Generators::FileTree::Writer.new(@config, @base)
  end

  def go
    @writer.start

    throw_traverser_on_queue Traverser.new(@config, self)
    process_queue

    @writer.finish
  end

  def process_queue
    until @queue.empty?
      traverser = @queue.shift
      @traverser_count += 1
      traverser.scan
    end
    puts "Traverser Count = #{ @traverser_count }"
  end
  
  def throw_traverser_on_queue traverser
    @queue << traverser
  end

  def save path, content, tags
    @writer.save path, content, tags
  end

  def documenter_for file_name
    self.class.documenters[file_name.split('.').last]
  end

  def self.documenters
    @documenters ||= Hash.new
  end
end

require_relative 'wudoc/concerns'
require_relative 'wudoc/concerns/markdown'
require_relative 'wudoc/configuration'
require_relative 'wudoc/traverser'
require_relative 'wudoc/generators'
require_relative 'wudoc/generators/file_tree'
require_relative 'wudoc/generators/file_tree/writer'
require_relative 'wudoc/documenters'
require_relative 'wudoc/documenters/ruby'
require_relative 'wudoc/documenters/markdown'