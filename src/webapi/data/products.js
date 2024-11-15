const products = [
  {
    _id: '5d7a514b5d2c12c7449be046',
    user: '1d7a514b5d2c12c7449be001',
    name: 'Airpods Wireless Bluetooth Headphones',
    image: '/images/airpods.jpg',
    description:
      'Bluetooth technology lets you connect it with compatible devices wirelessly High-quality AAC audio offers immersive listening experience Built-in microphone allows you to take calls while working',
    brand: 'Apple',
    category: 'Electronics',
    price: 89.99,
    countInStock: 10,
  },
  {
    _id: '5d725a037b292f5f8ceff787',
    user: '1d7a514b5d2c12c7449be001',
    name: 'iPhone 11 Pro 256GB Memory',
    image: '/images/phone.jpg',
    description:
      'Introducing the iPhone 11 Pro. A transformative triple-camera system that adds tons of capability without complexity. An unprecedented leap in battery life',
    brand: 'Apple',
    category: 'Electronics',
    price: 599.99,
    countInStock: 7,
    reviews: [
      {
        user: '3c8a1d5b0190b214360dc003',
        name: 'Mili Jha',
        comment: 'Awesome product, I love it!',
        rating: 5,
      },
    ],
    rating: 5,
  },
  {
    _id: '5d725a1b7b292f5f8ceff788',
    user: '1d7a514b5d2c12c7449be001',
    name: 'Cannon EOS 80D DSLR Camera',
    image: '/images/camera.jpg',
    description:
      'Characterized by versatile imaging specs, the Canon EOS 80D further clarifies itself using a pair of robust focusing systems and an intuitive design',
    brand: 'Cannon',
    category: 'Electronics',
    price: 929.99,
    countInStock: 5,
    rating: 3,
  },
  {
    _id: '5d726d107b292f5f8ceff796',
    user: '1d7a514b5d2c12c7449be001',
    name: 'Sony Playstation 4 Pro White Version',
    image: '/images/playstation.jpg',
    description:
      'The ultimate home entertainment center starts with PlayStation. Whether you are into gaming, HD movies, television, music',
    brand: 'Sony',
    category: 'Electronics',
    price: 399.99,
    countInStock: 11,
    rating: 5,
  },
  {
    _id: '5d726d917b292f5f8ceff797',
    user: '1d7a514b5d2c12c7449be001',
    name: 'Logitech G-Series Gaming Mouse',
    image: '/images/mouse.jpg',
    description:
      'Get a better handle on your games with this Logitech LIGHTSYNC gaming mouse. The six programmable buttons allow customization for a smooth playing experience',
    brand: 'Logitech',
    category: 'Electronics',
    price: 49.99,
    countInStock: 7,
    rating: 3.5,
  },
  {
    _id: '5d726e0b7b292f5f8ceff798',
    user: '1d7a514b5d2c12c7449be001',
    name: 'Amazon Echo Dot 3rd Generation',
    image: '/images/alexa.jpg',
    description:
      'Meet Echo Dot - Our most popular smart speaker with a fabric design. It is our most compact smart speaker that fits perfectly into small space',
    brand: 'Amazon',
    category: 'Electronics',
    price: 29.99,
    countInStock: 0,
    rating: 4,
  },
];

export default products;
