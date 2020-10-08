require 'redcarpet'

class Wudoc::Documenters::Markdown
  include Concerns::Markdown

  def initialize base, path, config={}
    @base = base
    @path = path
    @options = {}
  end

  def process
    @base.save(@path, render_markdown(content.join("\n")), ['documents'])
  end

  def content
    File.readlines(@path)
  end
end

Wudoc.documenters['md'] = Wudoc::Documenters::Markdown
