require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Tables do
  include_context 'pdf_helpers'

  LOGO_DIMENSION = [100, 38].freeze

  it 'renders an image on own line' do
    processor.parse("hello <img src=\"#{encode_image('logo.png')}\" style=\"width: 50mm;\"> world")

    scaled_height = 50.mm * LOGO_DIMENSION.last / LOGO_DIMENSION.first
    expect(text.strings).to eq(%w[hello world])
    expect(left_positions).to eq([left, left])
    expect(top_positions).to eq([top, top - line - scaled_height - p_gap].map(&:round))
  end

  it 'renders placeholder for unknown format' do
    processor.parse('hello <img src="data:image/bmp;bla,foobar"> world')

    expect(text.strings).to eq(['hello', '[unsupported image]', 'world'])
    expect(left_positions).to eq([left, left, left])
    expect(top_positions).to eq([top, top - line, top - 2 * line].map(&:round))
  end

  it 'renders image for remote src' do
    processor.parse('<p>hello</p><p><img src="https://github.com/puzzle/prawn-markup/blob/master/spec/fixtures/logo.png?raw=true"></p><p>world</p>')

    expect(text.strings).to eq(['hello', 'world'])
    expect(left_positions).to eq([left, left])
    expect(top_positions).to eq([top, top - line - LOGO_DIMENSION.last - p_gap - 5].map(&:round))
  end

  it 'renders unsupported image for remote src' do
    processor.parse('<p>hello</p><p><img src="https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif"></p><p>world</p>')
    expect(text.strings).to eq(['hello', '[unsupported image]', 'world'])
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

  context 'with custom loader' do
    let(:options) { { image: { loader: ->(src) { "spec/fixtures/#{src}" } } } }

    it 'render image with custom loader' do
      processor.parse('<p>hello</p><img src="logo.png"><p>world</p>')

      expect(left_positions).to eq([left, left])
      expect(top_positions).to eq([top, top - line - LOGO_DIMENSION.last - p_gap - 5].map(&:round))
    end

  end
end
