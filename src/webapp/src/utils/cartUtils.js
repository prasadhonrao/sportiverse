import { addDecimals } from './numberUtils';

export const updateCart = (state) => {
  // Calculate items price
  state.itemsPrice = addDecimals(state.cartItems.reduce((acc, item) => acc + item.price * item.quantity, 0));

  // Calculate shipping price (free shipping if items price > 100 otherwise 10)
  state.shippingPrice = addDecimals(state.itemsPrice > 100 ? 0 : 10);

  // Calculate tax price (15% of items price)
  state.taxPrice = addDecimals(Number((0.15 * state.itemsPrice).toFixed(2)));

  // Calculate total price
  state.totalPrice = (Number(state.itemsPrice) + Number(state.shippingPrice) + Number(state.taxPrice)).toFixed(2);

  localStorage.setItem('cart', JSON.stringify(state));

  return state;
};
