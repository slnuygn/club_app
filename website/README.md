# Club App Website

Modern, responsive landing page for the Club App mobile application.

## Features

- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Smooth Animations**: Scroll-triggered animations and smooth transitions
- **Modern UI**: Dark theme with custom color palette
- **React-based**: Built with React for optimal performance
- **Sections**:
  - Hero section with call-to-action
  - Features showcase
  - Screenshots carousel
  - Download section with store buttons
  - Footer with links

## Color Scheme

- Primary: `#282323`
- Secondary: `#121212`
- Tertiary: `#1B1B1B`
- Accent: `#807373`

## Getting Started

### Installation

```bash
npm install
```

### Development

```bash
npm start
```

Opens the development server at [http://localhost:3000](http://localhost:3000)

### Production Build

```bash
npm run build
```

Builds the app for production to the `dist` folder.

## Customization

### Adding Images

Replace the image placeholders in the components:

- Hero section: `src/components/Hero.js`
- Screenshots: `src/components/Screenshots.js`

### Updating Content

Edit the content in each component file:

- `src/components/Hero.js` - Main headline and description
- `src/components/Features.js` - Feature cards
- `src/components/Screenshots.js` - App screenshots
- `src/components/Download.js` - Download statistics
- `src/components/Footer.js` - Footer information

## Project Structure

```
website/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── Navbar.js
│   │   ├── Hero.js
│   │   ├── Features.js
│   │   ├── Screenshots.js
│   │   ├── Download.js
│   │   └── Footer.js
│   ├── styles/
│   │   ├── global.css
│   │   ├── App.css
│   │   ├── Navbar.css
│   │   ├── Hero.css
│   │   ├── Features.css
│   │   ├── Screenshots.css
│   │   ├── Download.css
│   │   └── Footer.css
│   ├── App.js
│   └── index.js
├── package.json
├── webpack.config.js
└── .babelrc
```

## Technologies Used

- React 18
- Webpack 5
- Babel
- CSS3 with modern features
- ES6+ JavaScript

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## License

MIT
