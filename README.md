# SkinAI v3 Plugin SDK - Integration Examples

Official integration examples for the PulpoAR SkinAI v3 plugin, demonstrating how to integrate the SDK into different platforms and receive real-time events.

## Available Examples

### [HTML/JavaScript Example](./html-js-example)
Web-based integration using vanilla JavaScript and WebView.

**Best for**: Web applications, Electron apps, or understanding the core SDK integration

### [Kotlin/Android Example](./kotlin-skinai-example)
Native Android integration using Kotlin and WebView.

**Best for**: Native Android applications, mobile apps

## Quick Links

- [Type Definitions](#type-definitions)
- [SDK Events](#sdk-events-17-total)
- [Integration Guide](#integration-guide)

---

## Type Definitions

Below are the TypeScript-style interface definitions for objects used in event payloads. These types are based on the official `@pulpoar/plugin-sdk` source code.

### ProductWithoutRoutines
Product object without nested routine data. This is the type returned in SDK events.

```javascript
{
  id: string,
  name: string | null,
  brand: string,              // Brand ID or name
  category: string,            // Category ID
  customSlug: string,
  price: number,
  problems: Array<{
    issue: string,
    name: string
  }>,
  aiSimulator?: Array<{       // Optional AI simulator configuration
    name: string,
    levels: Array<{
      name: string,
      image: string,
      masks: Array<{
        name: string,
        opacity: number,
        smooth: number
      }>
    }>
  }>
  // Additional product fields from your configuration
}
```

### RoutineWithoutProducts
Routine object without nested product data. This is the type returned in SDK events.

```javascript
{
  id: string,
  name: string | null,
  slug: string | null,
  stepName: string | null,
  sort: number | null,
  date_created: string | null,
  date_updated: string | null
  // Additional routine fields from your configuration
}
```

### SkinaiQuestion
Question object structure used in questionnaire events.

```javascript
{
  id: string,
  header: string,
  description: string,
  answers: SkinaiApiAnswer[],
  hasAnswerImage: boolean,
  hasAnswerDescription: boolean,
  selectionType: "single" | "multiple",
  position: { x: number, y: number },
  image?: string,
  initial: boolean,
  sort: number
}
```

### SkinaiApiAnswer
Answer object for questionnaire responses.

```javascript
{
  id: string,
  header?: string,
  description?: string,
  image?: string,
  position: { x: number, y: number },
  target?: string
}
```

### SkinIssue
Skin issue/problem detected in analysis.

```javascript
{
  id: string,
  name: string,
  score: number  // Score value (typically 0-100)
}
```

---

## SDK Events (17 total)

All events are available through the `pulpoar` SDK object. Subscribe to events before the SDK initializes.

### Core

#### `onReady`
SDK initialized with project data.

**Payload:**
```javascript
{
  projectKey: string,
  themeType: "light" | "dark"
}
```

**Usage:**
```javascript
pulpoar.onReady(data => {
  console.log('SDK Ready:', data.projectKey)
})
```

---

### Navigation

#### `onPathChange`
Navigation path changed within the plugin.

**Payload:**
```javascript
{
  referer: string,  // Previous path
  path: string      // New path
}
```

**Usage:**
```javascript
pulpoar.onPathChange(data => {
  console.log('Navigation:', data.referer, '→', data.path)
})
```

---

### Onboarding

#### `onOnboardingCarouselChange`
Onboarding carousel step changed.

**Payload:**
```javascript
{
  fromStep: number,
  toStep: number
}
```

**Usage:**
```javascript
pulpoar.onOnboardingCarouselChange(data => {
  console.log('Onboarding step:', data.toStep)
})
```

---

### Questionnaire

#### `onQuestionnaireComplete`
User completed the skin questionnaire.

**Payload:**
```javascript
{
  questionsAndAnswers: Array<{
    question: SkinaiQuestion,
    answers: SkinaiApiAnswer[]
  }>
}
```

**Usage:**
```javascript
pulpoar.onQuestionnaireComplete(data => {
  console.log('Questionnaire completed:', data.questionsAndAnswers)
})
```

---

### Photo & Analysis

#### `onPhotoUse`
Photo selected for analysis (no payload).

**Usage:**
```javascript
pulpoar.onPhotoUse(() => {
  console.log('Photo selected')
})
```

#### `onPhotoRetake`
User requested to retake photo (no payload).

**Usage:**
```javascript
pulpoar.onPhotoRetake(() => {
  console.log('Retake photo requested')
})
```

#### `onSkinScoreCalculate`
Skin analysis completed with results.

**Payload:**
```javascript
{
  skinHealthScore: number,    // 0-100
  isSelfie: boolean,
  issues: SkinIssue[]
}
```

**Usage:**
```javascript
pulpoar.onSkinScoreCalculate(data => {
  console.log('Skin Score:', data.skinHealthScore)
  console.log('Issues found:', data.issues.length)
})
```

---

### Experience

#### `onExperienceChange`
User switched between skin analysis and AI simulation experiences.

**Payload:**
```javascript
{
  experience: "skin-analysis" | "ai-simulation"
}
```

**Usage:**
```javascript
pulpoar.onExperienceChange(data => {
  console.log('Experience changed to:', data.experience)
})
```

---

### Recommendations

#### `onRecommendationsReceive`
Product recommendations received based on skin analysis.

**Payload:**
```javascript
{
  products: ProductWithoutRoutines[],
  routines: RoutineWithoutProducts[],
  isSelfie: boolean
}
```

**Usage:**
```javascript
pulpoar.onRecommendationsReceive(data => {
  console.log('Received recommendations:')
  console.log('- Products:', data.products.length)
  console.log('- Routines:', data.routines.length)
})
```

---

### Product Interactions

#### `onProductTryClick`
User clicked to try a product in AR/simulation.

**Payload:**
```javascript
{
  product: ProductWithoutRoutines
}
```

**Usage:**
```javascript
pulpoar.onProductTryClick(data => {
  console.log('Product try clicked:', data.product.name)
})
```

#### `onAISimulatorAdjust`
User adjusted AI simulator controls (problem severity level).

**Payload:**
```javascript
{
  product: ProductWithoutRoutines,
  problem: string,
  level: number
}
```

**Usage:**
```javascript
pulpoar.onAISimulatorAdjust(data => {
  console.log(`Adjusted ${data.problem} to level ${data.level}`)
})
```

#### `onAddToCart`
User added product(s) to cart.

**Payload:**
```javascript
{
  products: ProductWithoutRoutines[],
  routine?: RoutineWithoutProducts,
  source: "routines" | "products",
  experience: "skin-analysis" | "ai-simulation"
}
```

**Usage:**
```javascript
pulpoar.onAddToCart(data => {
  console.log('Add to cart:', data.products.length, 'products')
  console.log('Source:', data.source)

  // Add products to your e-commerce cart
  data.products.forEach(product => {
    addToCart(product.id, product.price)
  })
})
```

#### `onProductVisit`
User clicked to visit product page.

**Payload:**
```javascript
{
  product: ProductWithoutRoutines,
  routine?: RoutineWithoutProducts,
  isSelfie: boolean,
  source: "routines" | "products",
  experience: "skin-analysis" | "ai-simulation"
}
```

**Usage:**
```javascript
pulpoar.onProductVisit(data => {
  // Navigate to product page
  window.location.href = `/products/${data.product.customSlug}`
})
```

---

### Email

#### `onEmailButtonClick`
User clicked the email button.

**Payload:**
```javascript
{
  isSelfie: boolean
}
```

**Usage:**
```javascript
pulpoar.onEmailButtonClick(data => {
  console.log('Email button clicked')
})
```

#### `onEmailSend`
User sent email with analysis results.

**Payload:**
```javascript
{
  isSelfie: boolean
}
```

**Usage:**
```javascript
pulpoar.onEmailSend(data => {
  console.log('Email sent successfully')
})
```

---

### Camera

#### `onCameraPermissionDeny`
Camera permission was denied by user (no payload).

**Usage:**
```javascript
pulpoar.onCameraPermissionDeny(() => {
  console.log('Camera permission denied')
  // Show message to user about enabling camera
})
```

---

### UI Interactions

#### `onProblemChipClick`
User clicked on a skin problem/issue chip.

**Payload:**
```javascript
{
  problem: string,
  isSelfie: boolean
}
```

**Usage:**
```javascript
pulpoar.onProblemChipClick(data => {
  console.log('Problem chip clicked:', data.problem)
})
```

---

## Integration Guide

### 1. Load the SDK

**HTML/JavaScript:**
```html
<script src="https://cdn.jsdelivr.net/npm/@pulpoar/plugin-sdk@latest/dist/index.iife.js"></script>
```

**Kotlin/Android (WebView):**
```kotlin
val script = """
  const script = document.createElement('script');
  script.src = 'https://cdn.jsdelivr.net/npm/@pulpoar/plugin-sdk@latest/dist/index.iife.js';
  document.body.appendChild(script);
"""
webView.evaluateJavascript(script, null)
```

### 2. Subscribe to Events

Events must be subscribed **before** the SDK initializes.

**HTML/JavaScript:**
```javascript
// Subscribe to events
pulpoar.onReady(data => console.log('Ready:', data))
pulpoar.onSkinScoreCalculate(data => console.log('Score:', data))
pulpoar.onAddToCart(data => {
  // Add to your cart
  addProductsToCart(data.products)
})

// Other events...
```

**Kotlin/Android:**
```kotlin
// Create JavascriptInterface
class SDKInterface {
    @JavascriptInterface
    fun onReady(payload: String) {
        val data = JSONObject(payload)
        Log.d("SkinAI", "Ready: ${data.getString("projectKey")}")
    }

    @JavascriptInterface
    fun onAddToCart(payload: String) {
        val data = JSONObject(payload)
        // Add to cart logic
    }
}

// Add to WebView
webView.addJavascriptInterface(SDKInterface(), "AndroidInterface")

// Subscribe via JavaScript
val subscribeScript = """
  pulpoar.onReady((payload) => {
    AndroidInterface.onReady(JSON.stringify(payload))
  })
  pulpoar.onAddToCart((payload) => {
    AndroidInterface.onAddToCart(JSON.stringify(payload))
  })
"""
```

### 3. Embed the Plugin

**HTML/JavaScript:**
```html
<iframe
  src="https://plugin.pulpoar.com/skinai/YOUR_PROJECT_SLUG"
  allow="camera *"
  title="SkinAI Plugin"
></iframe>
```

**Kotlin/Android:**
```kotlin
webView.settings.javaScriptEnabled = true
webView.settings.domStorageEnabled = true
webView.loadUrl("https://plugin.pulpoar.com/skinai/YOUR_PROJECT_SLUG")
```

### 4. Handle Product Events

Common integration pattern for e-commerce:

```javascript
// Add to Cart
pulpoar.onAddToCart(data => {
  data.products.forEach(product => {
    // Call your cart API
    fetch('/api/cart/add', {
      method: 'POST',
      body: JSON.stringify({
        productId: product.id,
        quantity: 1,
        source: 'skinai'
      })
    })
  })
})

// Product Page Visit
pulpoar.onProductVisit(data => {
  // Navigate to product page
  window.location.href = `/products/${data.product.customSlug}`
})
```

---

## Browser Compatibility

- **Chrome**: 90+
- **Firefox**: 88+
- **Safari**: 14+
- **Edge**: 90+

**Note**: Camera access requires HTTPS in production.
