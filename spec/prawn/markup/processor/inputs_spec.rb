require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Inputs do
  include_context 'pdf_helpers'

  let(:options) { { input: { symbol_font: 'DejaVu', radio: { unchecked: '❍' } } } }

  before do
    doc.font_families.update('DejaVu' => {
      normal: 'spec/fixtures/DejaVuSans.ttf'
    })
  end

  it 'handles checkboxes' do
    processor.parse('<input type="checkbox" checked="checked"/> One<br/><input type="checkbox" /> Two')
    expect(text.strings).to eq(['☑', ' One', '☐', ' Two'])
    expect(font_names).to eq(%w[DejaVuSans Helvetica DejaVuSans Helvetica])
  end

  it 'handles checkboxes in tables' do
    processor.parse('<table><tr><td><input type="checkbox"/></td><td>One</td></tr>' \
                    '<tr><td><input type="checkbox" checked/></td><td>Two</td></tr></table>')
    expect(text.strings).to eq(['☐', 'One', '☑', 'Two'])
  end

  it 'handles radios' do
    processor.parse('<input type="radio" checked="checked"/> One<br/><input type="radio" /> Two')
    expect(text.strings).to eq(['◉', ' One', '❍', ' Two'])
    expect(font_names).to eq(%w[DejaVuSans Helvetica DejaVuSans Helvetica])
  end

  it 'ignores text inputs' do
    processor.parse('Eingabe: <input type="text" value="foo" />')
    expect(text.strings).to eq(['Eingabe:'])
  end

  private

  def font_names
    text.font_settings.map { |h| h[:name].to_s.gsub(/^[1-9a-z]{6}\+/, '') }
  end
end
