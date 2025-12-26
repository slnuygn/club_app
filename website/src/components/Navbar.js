import React, { useState } from 'react';
import '../styles/Navbar.css';

const Navbar = ({ scrollY }) => {
  const [isOpen, setIsOpen] = useState(false);

  const scrollToSection = (id) => {
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
      setIsOpen(false);
    }
  };

  return (
    <nav className={`navbar ${scrollY > 50 ? 'scrolled' : ''}`}>
      <div className="container navbar-container">
        <div className="navbar-logo">
          <h1>Huddle: Community Hub</h1>
        </div>

        <button 
          className={`navbar-toggle ${isOpen ? 'active' : ''}`}
          onClick={() => setIsOpen(!isOpen)}
        >
          <span></span>
          <span></span>
          <span></span>
        </button>

        <ul className={`navbar-menu ${isOpen ? 'active' : ''}`}>
          <li>
            <a onClick={() => scrollToSection('hero')}>Home</a>
          </li>
          <li>
            <a onClick={() => scrollToSection('features')}>Features</a>
          </li>
          <li>
            <a onClick={() => scrollToSection('screenshots')}>Pages</a>
          </li>
          <li>
            <a onClick={() => scrollToSection('download')}>Download</a>
          </li>
        </ul>
      </div>
    </nav>
  );
};

export default Navbar;
