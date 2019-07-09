require 'spec_helper'

RSpec.describe Prawn::Markup::Normalizer do
  it 'wraps text into root tags' do
    expect(normalize('hello world')).to eq('<body>hello world</body>')
  end

  it 'wraps html into root tags' do
    expect(normalize('<p>hello world</p>')).to eq('<body><p>hello world</p></body>')
  end

  it 'closes self-closing tags' do
    expect(normalize('1<br>2<hr>3')).to eq('<body>1<br/>2<hr/>3</body>')
  end

  it 'replaces html entities' do
    expect(normalize('2 &nbsp; 3')).to eq('<body>2   3</body>')
  end

  def normalize(html)
    Prawn::Markup::Normalizer.new(html).normalize
  end
end
