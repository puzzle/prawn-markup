# frozen_string_literal: true

module Prawn
  module Markup
    # Processes known HTML tags. Unknown tags are ignored.
    class Processor < Nokogiri::XML::SAX::Document
      class Error < StandardError; end

      class << self
        def known_elements
          @@known_elments ||= []
        end

        def logger
          @@logger
        end

        def logger=(logger)
          @@logger = logger
        end
      end

      self.logger = defined?(Rails) ? Rails.logger : nil

      require 'prawn/markup/processor/text'
      require 'prawn/markup/processor/blocks'
      require 'prawn/markup/processor/headings'
      require 'prawn/markup/processor/images'
      require 'prawn/markup/processor/inputs'
      require 'prawn/markup/processor/tables'
      require 'prawn/markup/processor/lists'

      prepend Prawn::Markup::Processor::Text
      prepend Prawn::Markup::Processor::Blocks
      prepend Prawn::Markup::Processor::Headings
      prepend Prawn::Markup::Processor::Images
      prepend Prawn::Markup::Processor::Inputs
      prepend Prawn::Markup::Processor::Tables
      prepend Prawn::Markup::Processor::Lists

      def initialize(pdf, options = {})
        super()
        @pdf = pdf
        @options = options
      end

      def parse(html)
        return if html.to_s.strip.empty?

        reset
        html = Prawn::Markup::Normalizer.new(html).normalize
        Nokogiri::HTML::SAX::Parser.new(self).parse(html) { |ctx| ctx.recovery = true }
      end

      def start_element(name, attrs = [])
        stack.push(name: name, attrs: attrs.to_h)
        send("start_#{name}") if known_element?(name) && respond_to?("start_#{name}", true)
      end

      def end_element(name)
        send("end_#{name}") if respond_to?("end_#{name}", true)
        stack.pop
      end

      def characters(string)
        # entities will be replaced again later by inline_format
        append_text(string.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;'))
      end

      def error(string)
        logger.info("SAX parsing error: #{string.strip}") if logger
      end

      def warning(string)
        logger.info("SAX parsing warning: #{string.strip}") if logger
      end

      private

      attr_reader :pdf, :stack, :text_buffer, :bottom_margin, :options

      def reset
        @stack = []
        @text_buffer = +''
      end

      def known_element?(name)
        self.class.known_elements.include?(name)
      end

      def append_text(string)
        text_buffer.concat(string)
      end

      def buffered_text?
        !text_buffer.strip.empty?
      end

      def dump_text
        text = process_text(text_buffer.dup)
        text_buffer.clear
        text
      end

      def put_bottom_margin(value)
        @bottom_margin = value
      end

      def inside_container?
        false
      end

      def current_attrs
        stack.last[:attrs]
      end

      def process_text(text)
        if options[:text] && options[:text][:preprocessor]
          if options[:text][:preprocessor].arity == 3
            options[:text][:preprocessor].call(
              text,
              stack.last ? stack.last[:name] : 'div',
              stack.last ? stack.last[:attrs].symbolize_keys : {}
            )
          else
            options[:text][:preprocessor].call(text)
          end
        else
          text
        end
      end

      def style_properties
        style = current_attrs['style']
        if style
          style.split(';').map { |p| p.split(':', 2).map(&:strip) }.to_h
        else
          {}
        end
      end

      def placeholder_value(keys, *args)
        placeholder = dig_options(*keys)
        return if placeholder.nil?

        if placeholder.respond_to?(:call)
          placeholder.call(*args)
        else
          placeholder.to_s
        end
      end

      def dig_options(*keys)
        keys.inject(options) { |opts, key| opts ? opts[key] : nil }
      end

      def logger
        self.class.logger
      end
    end
  end
end
