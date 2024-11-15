import { Helmet } from 'react-helmet-async';

const Meta = ({ title, description, keywords }) => {
  return (
    <Helmet>
      <title>{title}</title>
      <meta name="description" content={description} />
      <meta name="keyword" content={keywords} />
    </Helmet>
  );
};

Meta.defaultProps = {
  title: 'Welcome To Sportiverse',
  description: 'Sportiverse is an eCommerce platform dedicated to sports enthusiasts',
  keywords: 'sports, electronics ',
};

export default Meta;
