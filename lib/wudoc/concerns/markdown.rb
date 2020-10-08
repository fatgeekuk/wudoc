#:wudoc:{"tags": ["Concerns|Markdown","Markdown"]}
module Concerns::Markdown
  def markdown
    Redcarpet::Markdown.new(renderer, @options)
  end

  def renderer
    Redcarpet::Render::HTML
  end

  def render_markdown text
    markdown.render(text)
  end
end
