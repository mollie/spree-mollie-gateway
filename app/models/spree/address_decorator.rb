Spree::Address.class_eval do
  def active_merchant_hash
    {
      name: full_name,
      firstname: firstname,
      lastname: lastname,
      address1: address1,
      address2: address2,
      city: city,
      state: state_text,
      zip: zipcode,
      country: country.try(:iso),
      phone: phone
    }
  end
end
