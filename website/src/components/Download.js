import React, { useEffect, useRef, useState } from 'react';
import '../styles/Download.css';

const Download = () => {
  const [isVisible, setIsVisible] = useState(false);
  const sectionRef = useRef(null);

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

  return (
    <section id="download" className="section download" ref={sectionRef}>
      <div className="download-background">
        <div className="download-gradient"></div>
      </div>
      
      <div className="container">
        <div className={`download-content ${isVisible ? 'visible' : ''}`}>
          <h2 className="section-title">Ready to Get Started?</h2>
          <p className="section-subtitle">
            Download the app now and join thousands of active club members
          </p>
          
          <div className="download-buttons">
            <button className="btn btn-primary">Request Demo</button>
            <button className="btn btn-secondary">Go to GitHub</button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Download;
