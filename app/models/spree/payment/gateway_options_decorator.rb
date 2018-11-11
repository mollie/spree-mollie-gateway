Spree::Payment::GatewayOptions.class_eval do
  def lines_hash
    order.lines.map do |line|

    end
  end
end