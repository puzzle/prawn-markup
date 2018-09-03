module Prawn
  module Markup
    module Processor::Images
      ALLOWED_IMAGE_TYPES = %w[image/png image/jpeg].freeze

      def self.prepended(base)
        base.known_elements.push('img', 'iframe')
      end

      def start_img
        add_image_or_placeholder(current_attrs['src'])
      end

      def start_iframe
        placeholder = iframe_placeholder
        append_text("\n#{placeholder}\n") if placeholder
      end

      private

      def add_image_or_placeholder(data)
        img = image_properties(data)
        if img
          add_current_text
          add_image(img)
        else
          append_text("\n#{invalid_image_placeholder}\n")
        end
      end

      def add_image(img)
        # parse width in the current context
        img[:width] = SizeConverter.new(pdf.bounds.width).parse(style_properties['width'])
        pdf.image(img.delete(:image), img)
        put_bottom_margin(text_margin_bottom)
      end

      def image_properties(data)
        img = decode_base64_image(data)
        if img
          props = style_properties
          {
            image: StringIO.new(img),
            width: props['width'],
            position: convert_float_to_position(props['float'])
          }
        end
      end

      def decode_base64_image(data)
        match = data.match(/^data:(.*?);(.*?),(.*)$/)
        if match && ALLOWED_IMAGE_TYPES.include?(match[1])
          Base64.decode64(match[3])
        end
      end

      def convert_float_to_position(float)
        { nil => nil,
          'none' => nil,
          'left' => :left,
          'right' => :right }[float]
      end

      def invalid_image_placeholder
        placeholder_value(%i[image placeholder]) || '[unsupported image]'
      end

      def iframe_placeholder
        placeholder_value(%i[iframe placeholder], current_attrs['src'])
      end
    end
  end
end
