import React, { useEffect, useState } from 'react';
import '../styles/Hero.css';
import homeImage from '../../pages/home.png';

const Hero = () => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
  }, []);

  return (
    <section id="hero" className="hero">
      <div className="hero-background">
        <div className="hero-gradient"></div>
      </div>
      
      <div className="container hero-container">
        <div className={`hero-content ${isVisible ? 'visible' : ''}`}>
          <h1 className="hero-title">
            Connect, Engage,
            <br />
            <span className="gradient-text">Experience More</span>
          </h1>
          <p className="hero-description">
            Your ultimate companion for club management and community engagement.
            Discover events, connect with members, and stay updated.
          </p>
          <div className="hero-buttons">
            <button className="btn btn-primary">Request Demo</button>
            <button className="btn btn-secondary">Go to GitHub</button>
          </div>
        </div>
        
        <div className={`hero-image ${isVisible ? 'visible' : ''}`}>
          <img src={homeImage} alt="Club App Home Screen" className="app-screenshot" />
        </div>
      </div>
      
      <div className="scroll-indicator">
        <div className="mouse"></div>
      </div>
    </section>
  );
};

export default Hero;
