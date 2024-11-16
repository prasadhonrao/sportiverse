import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Footer from '../../components/Footer';

describe('Footer Component', () => {
  it('should render without errors and display the current year', () => {
    render(<Footer />);
    const year = new Date().getFullYear();
    const footerElement = screen.getByText(`Sportiverse © ${year}`);
    expect(footerElement).toBeInTheDocument();
  });
});
