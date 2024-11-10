import React from 'react';
import { Row, Col } from 'react-bootstrap';
import Product from '../components/Product';
import { useGetProductsQuery } from '../slices/productsApiSlice';

const HomePage = () => {
  const { data: products, isLoading = false, isError = false } = useGetProductsQuery();
  return (
    <>
      {isLoading && <h2>Loading...</h2>}
      {isError && <h2>Error</h2>}

      <Row>
        {products &&
          products.map((product) => (
            <Col key={product._id} sm={12} md={6} lg={4} xl={3}>
              <Product product={product} />
            </Col>
          ))}
      </Row>
    </>
  );
};

export default HomePage;