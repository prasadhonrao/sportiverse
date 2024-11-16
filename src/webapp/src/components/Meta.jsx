import { Helmet } from 'react-helmet-async';

const Meta = ({
  title = 'Welcome To Sportiverse',
  description = 'Sportiverse is an eCommerce platform dedicated to sports enthusiasts',
  keywords = 'sports, electronics',
}) => {
  return (
    <Helmet>
      <title>{title}</title>
      <meta name="description" content={description} />
      <meta name="keyword" content={keywords} />
    </Helmet>
  );
};

export default Meta;
