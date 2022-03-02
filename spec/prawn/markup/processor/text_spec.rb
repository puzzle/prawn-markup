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

  it 'handles prawn tags' do
    processor.parse('hello <color rgb="ff0000">world</color>')
    expect(text.strings).to eq(['hello ', 'world'])
  end  
end
