import React, { useEffect, useRef, useState } from 'react';
import '../styles/Screenshots.css';
import homeImage from '../../pages/home.png';
import savedImage from '../../pages/saved.png';
import searchImage from '../../pages/search.png';
import profileImage from '../../pages/profile.png';

const Screenshots = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const sectionRef = useRef(null);

  const screenshots = [
    { title: 'Home Screen', description: 'Your personalized dashboard', image: homeImage },
    { title: 'Events', description: 'Browse and join events', image: savedImage },
    { title: 'Community', description: 'Connect with members', image: searchImage },
    { title: 'Profile', description: 'Manage your account', image: profileImage },
  ];

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          setIsVisible(true);
        }
      },
      { threshold: 0.3 }
    );

    if (sectionRef.current) {
      observer.observe(sectionRef.current);
    }

    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setActiveIndex((prev) => (prev + 1) % screenshots.length);
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  return (
    <section id="screenshots" className="section screenshots" ref={sectionRef}>
      <div className="container">
        <h2 className="section-title">See It In Action</h2>
        <p className="section-subtitle">
          Experience the beautiful and intuitive interface
        </p>
        
        <div className={`screenshots-showcase ${isVisible ? 'visible' : ''}`}>
          <div className="screenshots-carousel">
            {screenshots.map((screenshot, index) => (
              <div
                key={index}
                className={`screenshot-item ${index === activeIndex ? 'active' : ''}`}
              >
                <img src={screenshot.image} alt={screenshot.title} className="app-screenshot" />
                <h4>{screenshot.title}</h4>
                <p>{screenshot.description}</p>
              </div>
            ))}
          </div>
          
          <div className="carousel-dots">
            {screenshots.map((_, index) => (
              <button
                key={index}
                className={`dot ${index === activeIndex ? 'active' : ''}`}
                onClick={() => setActiveIndex(index)}
              />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default Screenshots;
