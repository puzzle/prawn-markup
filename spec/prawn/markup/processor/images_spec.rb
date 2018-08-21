require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Tables do
  include_context 'pdf_helpers'

  it 'renders an image on own line' do
    processor.parse("hello <img src=\"#{encode_image('logo.png')}\" style=\"width: 50mm;\"> world")

    orig_img_dimension = [100, 38]
    scaled_height = 50.mm * 38 / 100
    gap = doc.font.line_gap + doc.font.descender
    expect(text.strings).to eq(%w[hello world])
    expect(left_positions).to eq([left, left])
    expect(top_positions).to eq([top, top - line - scaled_height - gap].map(&:round))
  end

  it 'renders placeholder for unknown format' do
    processor.parse('hello <img src="data:image/bmp;bla,foobar"> world')

    expect(text.strings).to eq(['hello ', '[unsupported image]', 'world'])
    expect(left_positions).to eq([left, left, left])
    expect(top_positions).to eq([top, top - line, top - 2 * line].map(&:round))
  end

  it 'renders nothing for iframes' do
    processor.parse('hello <iframe src="http://vimeo.com/42" /> world')

    expect(text.strings).to eq(['hello  world'])
    expect(top_positions).to eq([top].map(&:round))
  end

  context 'with placeholder' do
    let(:options) { { iframe: { placeholder: ->(url) { "[embeded content: <a href=\"#{url}\">#{url}</a>]" } } } }

    it 'renders placeholder for iframes if given' do
      processor.parse('hello <iframe src="http://vimeo.com/42" /> world')

      expect(text.strings).to eq(['hello ', '[embeded content: ', 'http://vimeo.com/42', ']', 'world'])
      expect(top_positions).to eq([top, *([top - line] * 3), top - 2 * line].map(&:round))
    end
  end
end
