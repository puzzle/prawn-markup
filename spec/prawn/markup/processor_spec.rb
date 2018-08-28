require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor do
  include_context 'pdf_helpers'

  it 'parses simple text' do
    processor.parse('hello')
    expect(text.strings).to eq(['hello'])
  end

  it 'parses simple html' do
    processor.parse('<p>hello</p><p>world</p>')
    expect(text.strings).to eq(%w[hello world])
    expect(left_positions).to eq([left, left])
    expect(top_positions).to eq([top, top - line - p_gap].map(&:round))
  end

  it 'renders entities correctly' do
    processor.parse('1 &lt; 2 &amp; 2 &gt; 1 &amp;amp; & &amp;auml; ä')
    expect(text.strings).to eq(['1 < 2 & 2 > 1 &amp; & &auml; ä'])
  end

  it 'handles empty attributes' do
    processor.parse('<b style>bold content</b> and more')
    expect(text.strings).to eq(['bold content', ' and more'])
  end

  it 'handles non-matching tags' do
    processor.parse('<p> is not closed')
    expect(text.strings).to eq(['is not closed'])
  end

  it 'handles invalid html' do
    processor.parse('here <i>is</i> <foo:div>text</foo:div> < with unescaped > & other </stuff>')
    expect(text.strings).to eq(['here ', 'is', ' text < with unescaped > & other'])
  end
end
