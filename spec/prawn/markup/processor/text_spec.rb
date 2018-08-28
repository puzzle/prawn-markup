require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Text do
  include_context 'pdf_helpers'

  it 'ignores additional whitespace' do
    processor.parse(" <div> hello  world </div>   <div> and \n  you\n</div>")
    expect(text.strings).to eq(['hello world', 'and you'])
    expect(top_positions).to eq([top, top - line].map(&:round))
  end

  it 'creates margin between paragraphs' do
    processor.parse('<p>hello</p><p>world</p>')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - line - p_gap].map(&:round))
  end

  it 'empty paragraphs are ignored' do
    processor.parse('<p>hello</p><p></p><p>world</p>')
    expect(top_positions).to eq([top, top - line - p_gap].map(&:round))
  end

  it 'empty paragraphs in divs are ignored' do
    processor.parse('<div>hello </p> <p> </div> <div>world</div>')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - 1 * line].map(&:round))
  end

  it 'paragraphs with only breaks are created' do
    processor.parse('<p>hello</p><p><br/></p><p>world</p>')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - 2 * (line + p_gap)].map(&:round))
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

  it 'creates new line for paragraphs in divs' do
    processor.parse('<div>hello<p>world</p></div>')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - line].map(&:round))
  end

  it 'does not double lines for nested divs' do
    processor.parse('<div>hello<div>world</div><div>markup</div></div>gone')
    expect(text.strings).to eq(%w[hello world markup gone])
    expect(top_positions).to eq([top, top - line, top - 2 * line, top - 3 * line].map(&:round))
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

  it 'creates horizontal line between paragraphs' do
    processor.parse('<p>hello</p><hr><p>world</p>')
    expect(text.strings).to eq(%w[hello world])
    expect(top_positions).to eq([top, top - 2 * line].map(&:round))
  end

  it 'creates links' do
    processor.parse('hello <a href="http://example.com">world</a>')
    expect(text.strings).to eq(['hello ', 'world'])
    expect(top_positions).to eq([top, top].map(&:round))
  end

  context 'with options' do
    let(:font_size) { 10 }
    let(:leading) { 4 }
    let(:options) do
      {
        text: {
          leading: leading,
          size: font_size,
          margin_bottom: 0,
          preprocessor: ->(text) { text.upcase }
        }
      }
    end

    it 'creates new line for breaks' do
      processor.parse('hello<br/>world')
      expect(text.strings).to eq(%w[HELLO WORLD])
      expect(top_positions).to eq([top, top - line].map(&:round))
    end

    it 'creates horizontal line' do
      processor.parse('hello<hr>world')
      expect(text.strings).to eq(%w[HELLO WORLD])
      expect(top_positions).to eq([top, top - 2 * line].map(&:round))
    end

    it 'adds no space between paragraphs' do
      processor.parse('<p>hello</p><p>world</p>')
      expect(text.strings).to eq(%w[HELLO WORLD])
      expect(top_positions).to eq([top, top - line].map(&:round))
    end

  end
end
