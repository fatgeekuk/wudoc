class Wudoc::Generators::FileTree::Writer
  attr_accessor :config

  def initialize config, base
    self.config = config
    @base = base
  end
  
  def start
    @file_list = []
    @tags      = []
  end

  def finish
    generate_frames
  end

  def save abs_path, content, tags
    path = abs_path.gsub(@base, '')

    dir_path = [@base, 'wudoc', path].join('/')
    tags.each do |tag|
      if !@tags.include?(tag)
        @tags << tag 
      end
    end

    FileUtils.mkdir_p(dir_path)
    template = ERB.new(File.read([writer_doc, 'templates', 'file_page.html.erb'].join('/')))
    
    File.open([@base, 'wudoc', path, 'documentation.html'].join('/'), 'wb') do |file|
      file.write(template.result(binding))
    end

    @file_list << {
      name: path.gsub(@base, ''),
      path: dir_path,
      tags: tags
    }
  end   
  
  def navigation_tree
    @tags.each_with_object(Hash.new) do |tag, nav_tree|
      chunks = tag.split('|')
      if chunks.length > 1
        nav_tree[chunks.first] ||= []
        nav_tree[chunks.first] << chunks.last
      else
        nav_tree[tag] = tag
      end
    end
  end

  def writer_doc
    File.dirname(__FILE__)
  end

  def doc_base
    @base + '/wudoc'
  end

  def generate_frames
    [
      {
        format: :erb,
        template: 'index.html.erb',
        target: 'wudoc/index.html'
      },
      {
        format: :erb,
        template: 'index-content.html.erb',
        target: 'wudoc/index-content-%T%.html',
        renderer: :index_render_tags,
        binding: :index_content
      },
      {
        format: :erb,
        template: 'root.html.erb',
        target: 'wudoc/root.html'
      },
      {
        format: :raw,
        template: 'styles.css',
        target: 'wudoc/styles.css'
      } 
    ].each do |definition|
      case definition[:renderer]
      when nil
        case definition[:format]
        when :erb
          b = definition[:binding].nil? ? binding : send(definition[:binding])
          template = ERB.new(File.read([writer_doc, 'templates', definition[:template]].join('/')))
          File.open(definition[:target], 'wb') do |file|
            file.write template.result(b)
          end
        when :raw
          File.open(definition[:target], 'wb') do |file|
            file.write File.read([writer_doc, 'templates', definition[:template]].join('/'))
          end
        end
      else
        send(definition[:renderer], definition)
      end
    end
  end

  def index_render_tags definition
    index_render_tag definition, nil
    @tags.each do |tag|
      index_render_tag definition, tag
    end
  end

  def render template_name, locals = {}
    b = binding
    locals.keys.each_with_index do |key, i|
      eval "#{ key } = locals[:#{ key }]", b
    end
    
    template = ERB.new(File.read([writer_doc, 'templates', "_#{ template_name }.html.erb"].join('/')))
    template.result(b)
  end

  def index_render_tag definition, tag
    list = tag.nil? ? @file_list : @file_list.select { |item| item[:tags].include? tag }

    # now build the tree from the list.
  
    tree = list.each_with_object(Hash.new) do |item, t|
      bits = item[:name].split('/')
      _ = bits.shift
      insert_point = t
      while bits.length > 1
        point = bits.shift
        insert_point = insert_point[point] ||= Hash.new
      end
      insert_point[bits.first] = item
    end

    template = ERB.new(File.read([writer_doc, 'templates', definition[:template]].join('/')))
    target = definition[:target].gsub('%T%', tag.to_s.gsub(/\|/, '-'))
    
    File.open(target, 'wb') do |file|
      file.write template.result(binding)
    end
  end

  def index_content
    list = @file_list
    binding
  end
end
