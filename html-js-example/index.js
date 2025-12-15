const CONFIG = {
  MAX_EVENTS_DISPLAY: 50,
  MAX_PAYLOAD_LENGTH: 5000,
  AUTO_HIDE_DELAY: 5000,
  SIDEBAR_EXPANDED_WIDTH: '350px',
  SIDEBAR_COLLAPSED_WIDTH: '40px',
  STORAGE_KEY: 'sidebarCollapsed',
}

const PATH_NAMES = {
  root: 'Home / Root',
}

function createOption(value, text) {
  const option = document.createElement('option')
  option.value = value
  option.textContent = text
  return option
}

function formatTimestamp(isoString) {
  return new Date(isoString).toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  })
}

function truncateJSON(data, maxLength) {
  const jsonString = JSON.stringify(data, null, 2)
  if (jsonString.length <= maxLength) return jsonString

  const remaining = jsonString.length - maxLength
  return `${jsonString.substring(0, maxLength)}\n\n... (truncated ${remaining} characters)`
}

function showMessage(elementId, message, type) {
  const element = document.getElementById(elementId)
  if (!element) return

  element.textContent = message
  element.className = `response-area ${type}`
  element.style.display = 'block'

  setTimeout(() => {
    element.style.display = 'none'
  }, CONFIG.AUTO_HIDE_DELAY)
}

// ============================================
// STATE MANAGEMENT
// ============================================

const state = {
  eventCount: 0,
  uiEventCount: 0,
  hasShownFirstEvent: false,
  projectData: null,
  isSidebarCollapsed: false,
}

const dom = {
  eventsLogContainer: null,
  eventCountBadge: null,
  eventsPanel: null,
  contentGrid: null,
}


// ============================================
// EVENT LOGGING & DISPLAY
// ============================================

function logEvent(eventName, payload) {
  const eventData = {
    timestamp: new Date().toISOString(),
    eventName,
    data: payload,
  }

  state.eventCount++
  updateEventCount()
  displayEvent(eventData)
}

function updateEventCount() {
  if (dom.eventCountBadge) {
    dom.eventCountBadge.textContent = state.eventCount
  }
}

function displayEvent(eventData) {
  if (!dom.eventsLogContainer) return

  if (!state.hasShownFirstEvent) {
    const emptyState = dom.eventsLogContainer.querySelector('.empty-state')
    if (emptyState) {
      emptyState.remove()
      state.hasShownFirstEvent = true
    }
  }

  const eventItem = document.createElement('div')
  eventItem.className = 'event-item'

  const timestamp = formatTimestamp(eventData.timestamp)
  const displayData = truncateJSON(eventData.data, CONFIG.MAX_PAYLOAD_LENGTH)

  eventItem.innerHTML = `
    <div class="event-header">
      <div class="event-name">${eventData.eventName}</div>
      <div class="event-time">${timestamp}</div>
    </div>
    <div class="event-data">
      <pre>${displayData}</pre>
    </div>
  `

  dom.eventsLogContainer.insertBefore(eventItem, dom.eventsLogContainer.firstChild)
  state.uiEventCount++

  if (state.uiEventCount > CONFIG.MAX_EVENTS_DISPLAY) {
    const lastChild = dom.eventsLogContainer.lastChild
    if (lastChild && lastChild.classList.contains('event-item')) {
      lastChild.remove()
      state.uiEventCount--
    }
  }
}

function clearEvents() {
  if (dom.eventsLogContainer) {
    dom.eventsLogContainer.innerHTML = `
      <div class="empty-state">
        <div class="empty-state-icon">📭</div>
        <div class="empty-state-text">No events yet</div>
        <div class="empty-state-subtext">Interact with the makeup experience to see events appear here</div>
      </div>
    `
  }

  state.eventCount = 0
  state.uiEventCount = 0
  state.hasShownFirstEvent = false
  updateEventCount()
}

// ============================================
// SDK EVENT HANDLING
// ============================================

function subscribeToEvents() {
  // Core events
  pulpoar.onReady(data => {
    state.projectData = data
    logEvent('onReady', data)
  })
  pulpoar.onError(error => logEvent('onError', error))

  // Navigation events
  pulpoar.onPathChange(data => logEvent('onPathChange', data))

 // Onboarding events
  pulpoar.onOnboardingCarouselChange(data => logEvent('onOnboardingCarouselChange', data))

  // Questionnaire events
  pulpoar.onQuestionnaireComplete(data => logEvent('onQuestionnaireComplete', data))

  // Photo events
  pulpoar.onPhotoUse(() => logEvent('onPhotoUse', undefined))
  pulpoar.onPhotoRetake(() => logEvent('onPhotoRetake', undefined))

  // Analysis events
  pulpoar.onSkinScoreCalculate(data => logEvent('onSkinScoreCalculate', data))

  // Experience events
  pulpoar.onExperienceChange(data => logEvent('onExperienceChange', data))

  // Recommendations events
  pulpoar.onRecommendationsReceive(data => logEvent('onRecommendationsReceive', data))

  // Product interaction events
  pulpoar.onProductTryClick(data => logEvent('onProductTryClick', data))
  pulpoar.onAISimulatorAdjust(data => logEvent('onAISimulatorAdjust', data))

  // Commerce events
  pulpoar.onAddToCart(data => logEvent('onAddToCart', data))
  pulpoar.onProductVisit(data => logEvent('onProductVisit', data))

  // Email events
  pulpoar.onEmailButtonClick(data => logEvent('onEmailButtonClick', data))
  pulpoar.onEmailSend(data => logEvent('onEmailSend', data))

  // Camera permission events
  pulpoar.onCameraPermissionDeny(() => logEvent('onCameraPermissionDeny', undefined))

  // Problem chip events
  pulpoar.onProblemChipClick(data => logEvent('onProblemChipClick', data))
}

// ============================================
// UI ACTION HANDLERS
// ============================================


function toggleSidebar() {
  if (!dom.eventsPanel || !dom.contentGrid) return

  state.isSidebarCollapsed = !state.isSidebarCollapsed

  if (state.isSidebarCollapsed) {
    dom.eventsPanel.classList.add('collapsed')
    dom.contentGrid.style.gridTemplateColumns = `1fr ${CONFIG.SIDEBAR_COLLAPSED_WIDTH}`
  } else {
    dom.eventsPanel.classList.remove('collapsed')
    dom.contentGrid.style.gridTemplateColumns = `1fr ${CONFIG.SIDEBAR_EXPANDED_WIDTH}`
  }
}

function toggleAccordion(button) {
  const content = button.nextElementSibling
  content.classList.toggle('active')
  button.classList.toggle('active')
}

// ============================================
// INITIALIZATION
// ============================================

document.addEventListener('DOMContentLoaded', function () {
  dom.eventsLogContainer = document.getElementById('events-log')
  dom.eventCountBadge = document.getElementById('event-count')
  dom.eventsPanel = document.querySelector('.events-panel')
  dom.contentGrid = document.querySelector('.content')

  subscribeToEvents()
})

// ============================================
// PUBLIC API
// ============================================

window.switchTab = switchTab
window.toggleSidebar = toggleSidebar
window.toggleAccordion = toggleAccordion
window.clearEvents = clearEvents
