require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Text do
  include_context 'pdf_helpers'

  it 'creates margin between paragraphs' do
    processor.parse('<p>hello</p><p>world</p>')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - 2 * line].map(&:round))
  end

  it 'creates new line for breaks' do
    processor.parse('hello<br/>world')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - line].map(&:round))
  end

  it 'creates new line between divs' do
    processor.parse('<div>hello</div><div>world</div>')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - line].map(&:round))
  end

  it 'ignores line breaks' do
    processor.parse("hello\t   you, \n world")
    expect(text.strings).to eq(['hello you, world'])
    expect(top_positions).to eq([top].map(&:round))
  end

  it 'handles inline formatting' do
    processor.parse('<strong>very <em>important</em></strong> <u>stuff</u> and regular one')
    expect(text.strings).to eq(['very ', 'important', ' stuff and regular one'])
    expect(text.font_settings.map { |h| h[:name] })
      .to eq(%i[Helvetica-Bold Helvetica-BoldOblique Helvetica])
  end

  it 'creates horizontal line' do
    processor.parse('hello<hr>world')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - 2 * line].map(&:round))
  end

  context 'with options' do
    let(:font_size) { 10 }
    let(:leading) { 4 }
    let(:options) do
      { text: { leading: leading, size: font_size } }
    end

    it 'creates new line for breaks' do
      processor.parse('hello<br/>world')
      expect(text.strings).to eq(%w[hello world])
      expect(top_positions).to eq([top, top - line].map(&:round))
    end

    it 'creates horizontal line' do
      processor.parse('hello<hr>world')
      expect(text.strings).to eq(%w[hello world])
      expect(top_positions).to eq([top, top - 2 * line].map(&:round))
    end
  end
end
