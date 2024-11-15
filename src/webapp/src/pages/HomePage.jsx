import React from 'react';
import { useParams } from 'react-router-dom';
import { Row, Col } from 'react-bootstrap';
import Product from '../components/Product';
import { useGetProductsQuery } from '../slices/productsApiSlice';

const HomePage = () => {
  const { pageNumber = 1 } = useParams();
  const { data, isLoading = false, isError = false } = useGetProductsQuery({ pageNumber });
  return (
    <>
      {isLoading && <h2>Loading...</h2>}
      {isError && <h2>Error</h2>}

      <Row>
        {data?.products?.map((product) => (
          <Col key={product._id} sm={12} md={6} lg={4} xl={3}>
            <Product product={product} />
          </Col>
        ))}
      </Row>
    </>
  );
};

export default HomePage;
