require 'parser/current'
require 'pry'

class Wudoc::Documenters::Ruby
  include Concerns::Markdown

  PRAGMA_PATTERN = /#:wudoc:([^\n]*)\n/

  def initialize base, path, config={}
    @base = base
    @path = path
    @config = config


    @output = :parsed_output
    
    handle_pragmas
    
    @content = ''
    @options = {}
    @output = @config['output'] || 'parsed'
    @tags = (['code', 'ruby'] + (@config['tags'] || [])).uniq

    @access_type = :public
  end

  def handle_pragmas
    pragmas.each do |pragma|
      begin
        @config = @config.merge(JSON.parse(pragma))
      rescue JSON::ParserError
        # Do nothing with a badly formed pragma.
      end
    end
  end

  def process
    case @output
    when 'verbatim'
      render_verbatim
    else
      begin
        traverse
        finish_content
      rescue Parser::SyntaxError
        render_failure "Unable to parse this file.\n"
      end
    end
    
    @base.save(@path, render_markdown(@content), @tags)
  end

  def render_failure message
    @content << "# File: #{ @path }"
    @content << "\n"
    @content << message
  end

  def render_verbatim
    @content << "# File: #{ @path }"
    @content << "\n"
    @content << "<pre class=\"verbatim code ruby-code\">\n"
    content.each { |line| @content << line }
    @content << "</pre>\n"
  end

  def traverse node = syntax_tree
    enter node
    if node.respond_to?(:children)
      node.children.each { |child| traverse child }
    end
    leave node
  end

  def enter node
    if node.respond_to?(:type)
      case node.type
      when :class
        handle_class node
      when :module
        handle_module node            
      when :def
        handle_def node
      when :send
        handle_send node
      else
        # puts "Unknown node #{ node.inspect }"
      end
    else
      # puts "#{ node.class.name } #{ node.inspect }"
    end
  end

  def leave node
  end

  def finish_content
  end

  def handle_def node
    name = node.children[0]
    params = node.children[1]
    param_str = params.loc.expression.nil? ? '' : content_str[params.loc.expression.begin_pos, params.loc.expression.end_pos]
    badge_type = {
      public: 'success',
      protected: 'warning', 
      private: 'danger'
    }[@access_type]
    @content << "Method: **#{ preserve_format(name) }** <span class=\"badge badge-#{ badge_type }\">#{ @access_type }</span>\n\n"
  end

  def handle_send node
    send_name = node.children[1]
    if [:public, :private, :protected].include? send_name
      @access_type = send_name
    end
  end

  def preserve_format string
    string.to_s.gsub('_') { |q| "\\#{ q }" }
  end

  def handle_class node
    class_str = build_const_str(node.children[0])
    parent_str = build_const_str(node.children[1])

    unless parent_str.nil?
      new_tag = "Subclass Of|#{ parent_str }"  
      @tags << new_tag if !@tags.include?(new_tag)
    end
    
    @content << "# Class: #{ class_str }"
    if !parent_str.nil?
      @content << " (subclass of #{ parent_str })"
    end
    @content << "\n\n"

    emit_comments(get_comments_before(node.loc))
  end

  def handle_module node
    module_str = build_const_str(node.children[0])
    
    @content << "# Module: #{ module_str }"
    @content << "\n\n"

    emit_comments(get_comments_before(node.loc))
  end

  def emit_comments comments
    @content << comments.collect do |comment|
      comment.text.gsub(/=(begin|end)/, '').gsub(/^#\s?q/, '')
    end.join("\n")
    @content << "\n"
  end

  def build_const_str node
    case
    when node.nil?
      nil
    when node.is_a?(Symbol)
      node.to_s
    when node.type == 'cbase'
      return ''
    else
      [build_const_str(node.children.first), build_const_str(node.children[1])].compact.join('::')
    end
  end

  def get_comments_before loc
    @comments.select { |c| c.loc.line < loc.line }.tap do |selection|
      @comments.select! { |c| c.loc.line > loc.line }
    end
  end

  def syntax_tree
    if @tree.nil?
      (@tree, @comments) = Parser::CurrentRuby.parse_with_comments(content.join(''))
    end
    
    @tree
  end

  def pragmas
    raw_content.select { |line| line.match(PRAGMA_PATTERN) }.collect { |prag| prag.gsub(PRAGMA_PATTERN, '\1') }
  end

  def content_str
    content.join('')
  end

  def content
    @incoming_content ||= raw_content.collect { |prag| prag.gsub(PRAGMA_PATTERN, '') }
  end

  def raw_content
    File.readlines(@path)
  end
end

Wudoc.documenters['rb'] = Wudoc::Documenters::Ruby
