module Prawn
  module Markup
    module Processor::Headings
      def self.prepended(base)
        base.known_elements.push('h1', 'h2', 'h3', 'h4', 'h5', 'h6')
      end

      (1..6).each do |i|
        define_method("start_h#{i}") do
          add_current_text(false)
          pdf.move_down(heading_options(i)[:margin_top] || 0)
        end

        define_method("end_h#{i}") do
          options = heading_options(i)
          add_current_text(false, options)
          pdf.move_down(options[:margin_bottom] || 0)
        end
      end

      private

      def heading_options(level)
        @heading_options ||= {}
        @heading_options[level] ||= default_options_with_size(level)
      end

      def default_options_with_size(level)
        default = text_options.dup
        default[:size] ||= pdf.font_size
        default[:size] *= 2.5 - level * 0.25
        HashMerger.deep(default, options[:"heading#{level}"] || {})
      end

    end
  end
end
