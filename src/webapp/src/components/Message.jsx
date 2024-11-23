import React from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'react-bootstrap';

const Message = ({ variant = 'info', children }) => {
  return <Alert variant={variant}>{children}</Alert>;
};

export default Message;

Message.propTypes = {
  variant: PropTypes.string,
  children: PropTypes.node.isRequired,
};
