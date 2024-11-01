require 'spec_helper'
require 'pdf_helpers'

RSpec.describe 'Showcase' do
  include_context 'pdf_helpers'

  it 'renders showcase' do
    html = File.read('spec/fixtures/showcase.html')
    doc.font_families.update('DejaVu' => {
      normal: 'spec/fixtures/DejaVuSans.ttf'
    })
    doc.markup_options = {
      heading1: { margin_top: 30, margin_bottom: 15 },
      heading2: { margin_top: 24, margin_bottom: 10, style: :italic },
      heading3: { margin_top: 20, margin_bottom: 5 },
      table: {
        header: { background_color: 'DDDDDD', style: :italic }
      },
      iframe: {
        placeholder: ->(src) { "Embedded content: #{src}" }
      },
      input: { symbol_font: 'DejaVu', symbol_font_size: 16 },
      link: { color: "AA0000", underline: true }
    }
    doc.markup(html)
    # lookatit
  end
end
