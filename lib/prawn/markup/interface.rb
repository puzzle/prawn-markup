module Prawn
  module Markup
    module Interface
      attr_accessor :markup_options

      def markup(html, options = {})
        options = markup_options.merge(options) if markup_options
        Processor.new(self, options).parse(html)
      end
    end
  end
end
