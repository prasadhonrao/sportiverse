import bcrypt from 'bcryptjs';

const users = [
  {
    name: 'Admin User',
    email: 'admin@gmail.com',
    password: bcrypt.hashSync('123456', 10),
    isAdmin: true,
  },
  {
    name: 'Bill Gates',
    email: 'bill@gmail.com',
    password: bcrypt.hashSync('123456', 10),
  },
  {
    name: 'Mili Jha',
    email: 'mili@gmail.com',
    password: bcrypt.hashSync('123456', 10),
  },
];

export default users;
