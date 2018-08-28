require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Interface do

  include_context 'pdf_helpers'

  let(:font_size) { 20 }

  it 'uses argument options' do
    doc.markup('<div>hello world</div><hr/><div>kthxbye</div>', text: { size: font_size })

    expect(text.strings).to eq(['hello world', 'kthxbye'])
    expect(top_positions).to eq([top, top - 2 * line].map(&:round))
  end

  it 'uses default options' do
    doc.markup_options[:text] = { size: font_size }
    doc.markup('<div>hello world</div><hr/><div>kthxbye</div>')

    expect(text.strings).to eq(['hello world', 'kthxbye'])
    expect(top_positions).to eq([top, top - 2 * line].map(&:round))
  end

  it 'merges both options' do
    doc.markup_options[:text] = { size: 8, style: :italic }
    doc.markup('<div>hello world</div><hr/><div>kthxbye</div>', text: { size: font_size })

    expect(text.strings).to eq(['hello world', 'kthxbye'])
    expect(top_positions).to eq([top, top - 2 * line].map(&:round))
  end

end
