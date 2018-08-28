require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Headings do

  include_context 'pdf_helpers'

  it 'creates various headings' do
    processor.parse('<h1>hello</h1><h2>world</h2><p>bla</p><h3>earthlings</h3><div>blu</div><h2>universe</h2><p>bli</p>')
    expect(text.strings).to eq(%w[hello world bla earthlings blu universe bli])
    # values copied from visually controlled run
    expect(top_positions).to eq([737, 708, 688, 668, 650, 628, 609])
  end

  it 'inline formatting in headings' do
    processor.parse('<h1>hello <i>world</i></h1><div>bla bla bla <h2>Subtitle</h2> blu blu</div>')
    expect(text.strings).to eq(['hello ', 'world', 'bla bla bla', 'Subtitle', 'blu blu'])
    # values copied from visually controlled run
    expect(top_positions).to eq([737, 737, 716, 694, 675])
  end

  context 'with options' do
    let(:options) do
      {
        heading1: { size: 36, style: :bold, margin_bottom: 5 },
        heading2: { size: 24, style: :bold_italic, margin_top: 20, margin_bottom: 5 }
      }
    end

    it 'customizes different headings' do
      processor.parse('<h1>hello</h1><h2>world</h2><p>bla</p><h5>earthlings</h5><div>blu</div><h2>universe</h2><p>bli</p>')
      expect(text.strings).to eq(%w[hello world bla earthlings blu universe bli])
      # values copied from visually controlled run
      expect(top_positions).to eq([730, 671, 646, 630, 615, 572, 547])
    end
  end

end
