class WallScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = %w( a abbr acronym address b big blockquote br cite code dd del dfn div dl dt em h1 h2 h3 h4 h5 h6 hr i img ins kbd li ol p pre samp small span strong sub sup time tt ul var style comment )
    self.attributes = %w( style )
  end

  def skip_node?(node)
    node.text?
  end
end