module Prawn
  module Markup
    module Processor::Text
      def self.prepended(base)
        base.known_elements.push('p', 'br', 'div', 'b', 'strong', 'i', 'em', 'u', 'a', 'hr')
      end

      def start_br
        append_text("\n")
      end

      def end_p
        append_text("\n\n") if buffered_text?
      end

      def end_div
        append_text("\n") if buffered_text?
      end

      def start_a
        append_text("<link href=\"#{current_attrs['href']}\">")
      end

      def end_a
        append_text('</link>')
      end

      def start_b
        append_text('<b>')
      end
      alias start_strong start_b

      def end_b
        append_text('</b>')
      end
      alias end_strong end_b

      def start_i
        append_text('<i>')
      end
      alias start_em start_i

      def end_i
        append_text('</i>')
      end
      alias end_em end_i

      def start_hr
        return if inside_container?

        add_current_text(true)
        pdf.move_down(hr_vertical_margin_top)
        pdf.stroke_horizontal_rule
        pdf.move_down(hr_vertical_margin_bottom)
      end

      def end_document
        add_current_text(true)
      end

      private

      def add_current_text(strip = false)
        return unless buffered_text?

        string = dump_text
        string.strip! if strip
        add_formatted_text(string)
      end

      def add_formatted_text(string)
        pdf.font(text_options[:font] || pdf.font.family, text_options.slice(:size, :style)) do
          pdf.text(string, text_options)
        end
      end

      def hr_vertical_margin_top
        @hr_vertical_margin_top ||=
          (text_options[:size] || pdf.font_size) / 2.0
      end

      def hr_vertical_margin_bottom
        @hr_vertical_margin_bottom ||= begin
          hr_vertical_margin_top + text_margin_bottom - text_font.line_gap - pdf.line_width
        end
      end

      def reset
        super
        text_margin_bottom # pre-calculate
      end

      def text_margin_bottom
        options[:text] ||= {}
        options[:text][:margin_bottom] ||= default_text_margin_bottom
      end

      def default_text_margin_bottom
        font = text_font
        font.line_gap +
          font.descender +
          (options[:text][:leading] || pdf.default_leading)
      end

      def text_font
        text_options[:font] ? pdf.find_font(text_options[:font]) : pdf.font
      end

      def text_options
        @text_options ||= HashMerger.deep(default_text_options, options[:text] || {})
      end

      def default_text_options
        {
          inline_format: true
        }
      end
    end
  end
end
