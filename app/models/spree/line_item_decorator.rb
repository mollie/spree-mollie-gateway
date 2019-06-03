Spree::LineItem.class_eval do
  money_methods :discount_amount, :vat_amount

  def discount_amount
    adjustments.non_tax.sum(:amount).abs
  end

  def vat_amount
    adjustments.tax.sum(:amount).abs
  end

  def mollie_identifier
    "#{line.id}-#{line.variant.sku}"
  end

  def vat_rate
    if adjustments.tax.any?
      # Spree allows line items to have multiple TaxRate adjustments.
      # Mollie does not support this. Raise an error if there > 1 TaxRate adjustment.
      if adjustments.tax.count > 1
        raise 'Mollie does not support multiple TaxRate adjustments per line item'
      end

      adjustments.tax.first.source.amount
    else
      0.00
    end
  end
end
