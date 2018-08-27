module Prawn
  module Markup
    module Interface
      attr_writer :markup_options

      def markup(html, options = {})
        options = markup_options.merge(options)
        Processor.new(self, options).parse(html)
      end

      def markup_options
        @markup_options ||= {}
      end

    end
  end
end
