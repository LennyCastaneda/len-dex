import { createStore, applyMiddleware, compose } from 'redux'
import { createLogger } from 'redux-logger'
import rootReducer from "./reducers";

const loggerMiddleware = createLogger()
const middleware = []

// For Redux Dev Tools
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose

// Create a Redux store holding the state of your app.
export default function configureStore(preloadedState) {
  return createStore(
    rootReducer,
    preloadedState,
    // Allow Redux logger to show us anytime an action is triggered
    composeEnhancers(applyMiddleware(...middleware, loggerMiddleware))
  )
}