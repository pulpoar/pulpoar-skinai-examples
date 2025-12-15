# SkinAI v3 Plugin SDK - HTML/JS Example

HTML/JavaScript integration example demonstrating SkinAI v3 plugin integration with event monitoring, SDK actions, and product interactions.

## Features

- **Full SkinAI v3 integration**: Complete skin analysis experience
- **Event logging**: Real-time monitoring of 18+ SDK events
- **SDK action controls**: Navigation, camera permissions, product interactions
- **Clean, declarative code**: Organized with constants, state management, and single-responsibility functions
- **Hot module replacement**: Powered by Vite for instant updates
- **Product integration**: AddToCart, ProductVisit, ProductTryClick event handlers

## Quick Start

```bash
npm install
npm run dev
```

Vite will start at `http://localhost:3000` and automatically open the demo page.

## Project Structure

```
skinai-html-js-example/
├── index.html         # Main demo page with full event logging
├── index.js           # SDK integration and event handlers
├── common.css         # Shared base styles and navigation
├── index.css          # Page-specific styles (same as makeup example)
├── vite.config.js     # Vite configuration
├── package.json       # Dependencies
└── README.md          # This file
```

## SDK Integration Reference

### Events (18 total)

All events are logged on the demo page with timestamps and payloads.

**Core**
- `onReady` - SDK initialized with project data
  ```javascript
  { projectKey: string, themeType: string }
  ```

**Navigation**
- `onPathChange` - Navigation path changed
  ```javascript
  { referer: string, path: string }
  ```

**Onboarding**
- `onOnboardingCarouselChange` - Onboarding carousel step changed
  ```javascript
  { fromStep: number, toStep: number }
  ```

**Questionnaire**
- `onQuestionnaireComplete` - User completed skin questionnaire
  ```javascript
  {
    questionsAndAnswers: Array<{
      question: SkinaiQuestion,
      answers: SkinaiApiAnswer[]
    }>
  }
  ```

**Photo & Analysis**
- `onPhotoUse` - Photo selected for analysis
- `onPhotoRetake` - User requested to retake photo
- `onSkinScoreCalculate` - Skin analysis completed
  ```javascript
  {
    skinHealthScore: number,
    isSelfie: boolean,
    issues: Array<{ id: string, name: string, score: number }>
  }
  ```

**Experience**
- `onExperienceChange` - User switched between experiences
  ```javascript
  { experience: "skin-analysis" | "ai-simulation" }
  ```

**Recommendations**
- `onRecommendationsReceive` - Product recommendations received
  ```javascript
  {
    products: ProductWithoutRoutines[],
    routines: RoutineWithoutProducts[],
    isSelfie: boolean
  }
  ```

**Product Interactions**
- `onProductTryClick` - User clicked to try a product
  ```javascript
  { product: ProductWithoutRoutines }
  ```

- `onAISimulatorAdjust` - User adjusted AI simulator
  ```javascript
  {
    product: ProductWithoutRoutines,
    problem: string,
    level: number
  }
  ```

- `onAddToCart` - User added product(s) to cart
  ```javascript
  {
    products: ProductWithoutRoutines[],
    routine?: RoutineWithoutProducts,
    source: "routines" | "products",
    experience: "skin-analysis" | "ai-simulation"
  }
  ```

- `onProductVisit` - User visited product page
  ```javascript
  {
    product: ProductWithoutRoutines,
    routine?: RoutineWithoutProducts,
    isSelfie: boolean,
    source: "routines" | "products",
    experience: "skin-analysis" | "ai-simulation"
  }
  ```

**Email**
- `onEmailButtonClick` - User clicked email button
  ```javascript
  { isSelfie: boolean }
  ```

- `onEmailSend` - User sent email with results
  ```javascript
  { isSelfie: boolean }
  ```

**Camera**
- `onCameraPermissionDeny` - Camera permission denied

**UI Interactions**
- `onProblemChipClick` - User clicked on a skin problem chip
  ```javascript
  { problem: string, isSelfie: boolean }
  ```

### Actions

**`setPath(path)`**

Navigate to specific pages within the plugin.

Paths: `opening`, `onboarding`, `questionnaire`, `take-photo`, `result`

```javascript
pulpoar.skinai.setPath('opening')      // Home/opening page
pulpoar.skinai.setPath('onboarding')   // Onboarding carousel
pulpoar.skinai.setPath('questionnaire') // Skin questionnaire
pulpoar.skinai.setPath('take-photo')   // Photo capture
pulpoar.skinai.setPath('result')       // Analysis results
```

## Demo Page Features

**Left Panel: SkinAI Experience**
- Full-screen iframe with SkinAI plugin
- Complete flow: onboarding → questionnaire → photo → analysis → recommendations

**Right Panel: Events & Actions**
- **Events Tab**: Real-time event logging with timestamps and payload details
- **Actions Tab**: SDK controls
  - Product Management: Simulated add to cart
  - Navigation Control: Navigate to different pages
  - Camera Control: Request/stop camera

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Format code
npm run format

# Lint code
npm run lint
```

## Integration Notes

1. **SDK Loading**: The SDK is loaded via CDN in the HTML:
   ```html
   <script src="https://cdn.jsdelivr.net/npm/@pulpoar/plugin-sdk@latest/dist/index.iife.js"></script>
   ```

2. **Event Subscription**: Subscribe to events before the SDK initializes:
   ```javascript
   pulpoar.skinai.onReady(data => {
     console.log('SDK Ready:', data)
   })
   ```

3. **Camera Permissions**: The SDK automatically requests camera permissions when navigating to the `take-photo` page.

4. **Product Integration**: Handle product events to integrate with your e-commerce platform:
   ```javascript
   pulpoar.skinai.onAddToCart(data => {
     // Add products to your cart
     console.log('Products to add:', data.products)
     console.log('Source:', data.source) // "routines" or "products"
     console.log('Experience:', data.experience) // "skin-analysis" or "ai-simulation"
   })

   pulpoar.skinai.onProductVisit(data => {
     // Navigate to product page
     window.location.href = `/product/${data.product.id}`
   })
   ```

## Browser Compatibility

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

Camera access requires HTTPS in production.
