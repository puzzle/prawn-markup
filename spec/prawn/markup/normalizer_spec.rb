require 'spec_helper'

RSpec.describe Prawn::Markup::Normalizer do
  it 'wraps text into root tags' do
    expect(normalize('hello world')).to eq('<root>hello world</root>')
  end

  it 'wraps html into root tags' do
    expect(normalize('<p>hello world</p>')).to eq('<root><p>hello world</p></root>')
  end

  it 'closes self-closing tags' do
    expect(normalize('1<br>2<hr>3')).to eq('<root>1<br/>2<hr/>3</root>')
  end

  it 'replaces html entities' do
    expect(normalize('2 &nbsp; 3')).to eq('<root>2   3</root>')
  end

  def normalize(html)
    Prawn::Markup::Normalizer.new(html).normalize
  end
end
