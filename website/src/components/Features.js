import React, { useEffect, useRef, useState } from 'react';
import '../styles/Features.css';

const Features = () => {
  const [visibleCards, setVisibleCards] = useState([]);
  const featuresRef = useRef(null);

  const features = [
    {
      icon: '🎯',
      title: 'Event Management',
      description: 'Create and manage club events with ease. Track attendance and engage members.'
    },
    {
      icon: '📋',
      title: 'Event Approval System',
      description: 'Board members submit events to supervisors (President/Co-President) for review. Pending events await approval before going live.'
    },
    {
      icon: '📱',
      title: 'Real-time Updates',
      description: 'Stay informed with instant notifications and live activity feeds.'
    },
    {
      icon: '🔒',
      title: 'Secure & Private',
      description: 'Your data is protected with enterprise-grade security measures.'
    },
    {
      icon: '⭐',
      title: 'Promotion & Recognition',
      description: 'Get your events approved and posted to the main feed. Active contributors can earn promotions and recognition.'
    },
    {
      icon: '📊',
      title: 'Analytics Dashboard',
      description: 'Track engagement metrics and grow your community effectively.'
    }
  ];

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const index = parseInt(entry.target.dataset.index);
            setVisibleCards((prev) => [...new Set([...prev, index])]);
          }
        });
      },
      { threshold: 0.2 }
    );

    const cards = featuresRef.current?.querySelectorAll('.feature-card');
    cards?.forEach((card) => observer.observe(card));

    return () => observer.disconnect();
  }, []);

  return (
    <section id="features" className="section features">
      <div className="container">
        <h2 className="section-title">Powerful Features</h2>
        <p className="section-subtitle">
          Everything you need to manage and grow your club community
        </p>
        
        <div className="features-grid" ref={featuresRef}>
          {features.map((feature, index) => (
            <div
              key={index}
              data-index={index}
              className={`feature-card ${visibleCards.includes(index) ? 'visible' : ''}`}
              style={{ transitionDelay: `${(index % 3) * 0.1}s` }}
            >
              <div className="feature-icon">{feature.icon}</div>
              <h3 className="feature-title">{feature.title}</h3>
              <p className="feature-description">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Features;
