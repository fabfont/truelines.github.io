module Jekyll
  class RenderNoteTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "<div class=\"alert alert-info\" role=\"alert\"><img src=\"/assets/images/common/tip.png\" height=\"42\" width=\"42\"/><span>NOTE :</span> <br/><br/>#{@text}</div>"
    end
  end
end

Liquid::Template.register_tag('render_note', Jekyll::RenderNoteTag)
