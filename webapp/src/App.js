import { Container } from 'react-bootstrap';
import Header from './components/Header';
import Footer from './components/Footer';
function App() {
  return (
    <>
      <Header />
      <main>
        <Container>
          <h1>Welcome to Sai Sports Shop</h1>
        </Container>
      </main>
      <Footer />
    </>
  );
}

export default App;
