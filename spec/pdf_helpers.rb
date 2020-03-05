require 'prawn'
require 'pdf/inspector'
require 'base64'

Prawn::Font::AFM.hide_m17n_warning = true

# use an own context for Prawn::Markup, as this might be extracted at some point
RSpec.shared_context 'pdf_helpers' do
  let(:font_size) { 12 }
  let(:leading) { 0 }
  let(:content_top) { 756 }
  let(:top) { content_top - font_size * 0.718 }
  let(:left) { 36 }
  let(:line) { font_size * 1.156 + leading }
  let(:line_gap) { doc.font_size(font_size) { return doc.font.descender } }
  let(:p_gap) { doc.font_size(font_size) { return doc.font.descender + doc.font.line_gap } }
  let(:content_width) { 540 }
  let(:table_padding) { Prawn::Markup::Builders::TableBuilder::DEFAULT_CELL_PADDING }
  let(:bullet_margin) { Prawn::Markup::Builders::ListBuilder::BULLET_MARGIN }
  let(:content_margin) { Prawn::Markup::Builders::ListBuilder::CONTENT_MARGIN }
  let(:list_vertical_margin) { Prawn::Markup::Builders::ListBuilder::VERTICAL_MARGIN }
  let(:bullet) { Prawn::Markup::Builders::ListBuilder::BULLET_CHAR }
  let(:bullet_width) { 4 }
  let(:ordinal_width) { 10 }
  let(:bullet_padding) { 1 }
  let(:additional_cell_padding_top) { p_gap / 2 }

  let(:options) { {} }
  let(:doc) { Prawn::Document.new }
  let(:processor) { Prawn::Markup::Processor.new(doc, options) }
  let(:pdf) { doc.render }
  let(:text) { PDF::Inspector::Text.analyze(pdf) }
  let(:left_positions) { text.positions.map(&:first).map(&:round) }
  let(:top_positions) { text.positions.map(&:last).map(&:round) }
  let(:images) do
    PDF::Inspector::XObject.analyze(pdf).page_xobjects.flat_map do |o|
      o.values.select { |v| v.hash[:Subtype] == :Image }
    end
  end

  def encode_image(file)
    binary = File.read('spec/fixtures/' + file)
    encoded = Base64.encode64(binary)
    "data:image/#{File.extname(file)[1..-1]};,#{encoded}"
  end

  def lookatit
    require 'tempfile'
    f = Tempfile.new(%w[spec- .pdf])
    f.close
    doc.render_file(f.path)
    command = /darwin/ =~ RUBY_PLATFORM ? 'open' : 'xdg-open'
    `#{command} #{f.path} &`
  ensure
    f.unlink
  end

end
