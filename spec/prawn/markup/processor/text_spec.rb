require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Text do
  include_context 'pdf_helpers'

  it 'handles inline formatting' do
    processor.parse('<strong>very <em>important</em></strong> <u>stuff</u> and regular one. ' \
                    '1m<sup>3</sup> H<sub>2</sub>O <strike>water</strike> ')
    expect(text.strings).to eq(['very ', 'important', ' ', 'stuff', ' and regular one. 1m',
                                '3', ' H', '2', 'O ', 'water'])
    expect(text.font_settings.map { |h| h[:name] })
      .to eq(%i[Helvetica-Bold Helvetica-BoldOblique Helvetica Helvetica Helvetica Helvetica
                Helvetica Helvetica Helvetica Helvetica])
  end

  it 'creates links' do
    processor.parse('hello <a href="http://example.com">world</a>')
    expect(text.strings).to eq(['hello ', 'world'])
    expect(top_positions).to eq([top, top].map(&:round))
  end

  it 'handles prawn color tag for rgb' do
    processor.parse('hello <color rgb="ff0000">world</color>')
    expect(text.strings).to eq(['hello ', 'world'])
  end

  it 'handles prawn color tag for cmyk' do
    processor.parse('hello <color c="22" m="55" y="79" k="30">world</color>')
    expect(text.strings).to eq(['hello ', 'world'])
  end  

  it 'handles prawn font name' do
    processor.parse('hello <font name="Courier">world</font>')
    expect(text.strings).to eq(['hello ', 'world'])
  end

  it 'handles prawn font size' do
    processor.parse('hello <font size="20">world</font>')
    expect(text.strings).to eq(['hello ', 'world'])
  end

  it 'handles prawn font character_spacing' do
    processor.parse('hello <font character_spacing="20">world</font>')
    expect(text.strings).to eq(['hello ', 'world'])
  end

  it 'handles prawn font multiple attributes' do
    processor.parse('hello <font name="Courier" size="20">world</font>')
    expect(text.strings).to eq(['hello ', 'world'])
  end
end
