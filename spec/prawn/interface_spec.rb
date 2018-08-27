require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Interface do

  include_context 'pdf_helpers'

  let(:font_size) { 20 }

  it 'uses argument options' do
    doc.markup('<p>hello world</p><hr/><p>kthxbye</p>', text: { size: font_size })

    expect(text.strings).to eq(['hello world', 'kthxbye'])
    expect(top_positions).to eq([top, top - 2 * line + 2].map(&:round))
  end

  it 'uses default options' do
    doc.markup_options[:text] = { size: font_size }
    doc.markup('<p>hello world</p><hr/><p>kthxbye</p>')

    expect(text.strings).to eq(['hello world', 'kthxbye'])
    expect(top_positions).to eq([top, top - 2 * line + 2].map(&:round))
  end

end
