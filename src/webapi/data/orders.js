const orders = [
  {
    _id: '6aed17da8bd4df507346b005',
    user: '3c8a1d5b0190b214360dc003',
    orderItems: [
      {
        name: 'iPhone 11 Pro 256GB Memory',
        quantity: 1,
        image: '/images/phone.jpg',
        price: 599.99,
        product: '5d725a037b292f5f8ceff787',
      },
    ],
    shippingAddress: {
      address: '123 Main St',
      city: 'San Francisco',
      postalCode: '94101',
      country: 'USA',
    },
    paymentMethod: 'PayPal',
    itemsPrice: 779.97,
    taxPrice: 78.0,
    shippingPrice: 10.0,
    totalPrice: 867.97,
    isPaid: true,
    paidAt: '2023-10-01T10:00:00Z',
    isDelivered: true,
    deliveredAt: '2023-10-03T10:00:00Z',
  },
  {
    _id: '5d7ff12f134c36a8d7269169',
    user: '2d7a514b5d2c12c7449be002',
    orderItems: [
      {
        name: 'Airpods Wireless Bluetooth Headphones',
        quantity: 1,
        image: '/images/airpods.jpg',
        price: 399.99,
        product: '5d7a514b5d2c12c7449be046',
      },
      {
        name: 'Logitech G-Series Gaming Mouse',
        quantity: 3,
        image: '/images/mouse.jpg',
        price: 49.99,
        product: '5d726d917b292f5f8ceff797',
      },
    ],
    shippingAddress: {
      address: '456 Elm St',
      city: 'Los Angeles',
      postalCode: '90001',
      country: 'USA',
    },
    paymentMethod: 'Credit Card',
    itemsPrice: 549.96,
    taxPrice: 54.99,
    shippingPrice: 15.0,
    totalPrice: 619.95,
    isPaid: false,
    isDelivered: false,
  },
];

export default orders;
