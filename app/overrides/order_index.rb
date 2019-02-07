Deface::Override.new(
    virtual_path: 'spree/admin/orders/index',
    name: 'add payment state for klarna orders',
    replace: '#listing_orders tbody td:nth-child(5)',
    partial: 'spree/admin/orders/index_payment_state_override'
)
