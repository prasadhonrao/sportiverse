import bcrypt from 'bcryptjs';

const users = [
  {
    _id: '1d7a514b5d2c12c7449be001',
    name: 'Admin User',
    email: 'admin@gmail.com',
    password: bcrypt.hashSync('123456', 10),
    isAdmin: true,
  },
  {
    _id: '2d7a514b5d2c12c7449be002',
    name: 'Bill Gates',
    email: 'bill@gmail.com',
    password: bcrypt.hashSync('123456', 10),
  },
  {
    _id: '3c8a1d5b0190b214360dc003',
    name: 'Mili Jha',
    email: 'mili@gmail.com',
    password: bcrypt.hashSync('123456', 10),
  },
];

export default users;
