#
# The configuration object is responsible for managing the state of the local config info.
# 
# ## The base configuration node.
#
# An initial configuration object is generated with the normal NEW operator at the base of the 
# directory tree being scanned.
# 
# All wudoc configuration files and pragmas format their information as JSON strings.
#
# Within this base directory the .wudoc.init file will be parsed.
#
# This file should contain the base configuration and an optional 'tree'. The tree will
# be used should you wish to have all configuration within the single file.
#
# The "tree" element has a structure of a hash tree where at each 'node' there are possibly two keys
# * "config" which will contain additional config settings for this node in the tree, these will
#            be deep merged into the the config for this directory node.
# * "items" which will contain a key for each subdirectory needing additional config information.
#           within these item values, the main tree structure is repeated.
#
# Once the .wudoc.init file is loaded, the next step is to add in any config from the tree for the
# current level of the directory tree.
#
# Then, the .wudoc.rc file is read in and deep merged with the other results.
# 
# ## Subsequent configuration nodes.
#
# Using the base node, we can load in the configuration for child items.
# This is accomplished by way of the 'descend' method.
#
# This will duplicate the current configuration, update the tree location, merge in any configuration
# from this, and then load the local '.wudoc.rb' file. 
#
# ### Styles
#
# In short, the configuration object supports two main styles of configuration.
#
# ### Local.
# 
# In this style, the configuration of sections of the project is defined in '.wudoc.rc' files scattered
# around your codebase. This is convenient and versatile, but does mean that the configuration is dispersed
# through the project.
#
# ### Centralised.
# 
# In this style, the configuration can be all held in the single .wudoc.init.
# 
# The configuration specific to sub sections of the project would be included in the 'tree' hierarchy
# within the .wudoc.init file.
#
# Note, this style does not yet remove the requirement for pragma based config within individual files.
#
class Wudoc::Configuration
  attr_accessor :location

  def initialize location
    self.location = location
    @state = {}

    load '.wudoc.init'
    puts "Current State is #{ @state.inspect }"
    @tree_location = @state['tree']
    read_from_tree
    load '.wudoc.rc'
  end

  def descend dir_name
    dup.tap do |sub_config|
      sub_config.location = [location, dir_name].join('/')
      sub_config.update dir_name
    end
  end

  def ignore_list
    @state['ignore']
  end

  def tags
    @state['tags'] || []
  end

  def document_root
    @state['document_root']
  end

  def [] key
    @state[key]
  end

  def merge other_data
    dup.tap do |new_config|
      new_config.merge! other_data
    end
  end

  protected

  def merge! other_data
    @state = deep_merge(@state, other_data)
  end

  def update dir_name
    puts "updating DIR #{ dir_name.inspect }"
    puts "tree location is currently #{ @tree_location.inspect }"
    if !@tree_location.nil? && 
       !@tree_location[dir_name].nil?
      @tree_location = @tree_location[dir_name]
      read_from_tree
    end
    load '.wudoc.rc'
  end

  private

  def load filename
    begin
      content = JSON.parse(File.read(path_to(filename)))
    rescue JSON::ParserError, Errno::ENOENT, Errno::ENOTDIR => e
      puts "encountered an error when reading #{ filename }, #{ e.inspect }"
      content = default_initial_config
    end
    @state = deep_merge(@state, content)
  end

  def read_from_tree
    puts "reading from tree location #{ @tree_location.inspect }"
    return if @tree_location.nil?
    return if @tree_location['.'].nil?
    @state = deep_merge(@state, @tree_location['.'])
  end

  def path_to filename
    [location, filename].join('/')
  end
  
  def deep_merge left, right
    return left + right if left.kind_of?(Array) && right.kind_of?(Array)
    return right if left.kind_of?(String) && right.kind_of?(String)
    
    left.merge(right) do |key, left_value, right_value|
      deep_merge(left_value, right_value)
    end
  end
  
  def default_initial_config
    {
      'document_root' => 'wudoc-new'
    }
  end
end
