class WallScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = %w( table th picture nav header footer ins kbd main marquee section map time area figure figcaption hgroup thead tbody tfoot details summary caption colgroup td tr link a abbr acronym address b big blockquote br cite code dd del dfn div dl dt em h1 h2 h3 h4 h5 h6 hr i img ins kbd li ol p pre samp small span strong sub sup time tt ul var style comment video audio source iframe relative-time )
    self.attributes = %w( behavior bgcolor direction hspace datetime scrollamount scrolldelay truespeed align valign vspace style src href class id width height alt land title rel colspan rowspan controls autoplay loop preload muted shape coords target )
  end

  def skip_node?(node)
    node.text?
  end
end