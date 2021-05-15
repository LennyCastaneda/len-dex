import { createStore, applyMiddleware, compose } from 'redux'
import { createLogger } from 'redux-logger'
import rootReducer from "./reducers";

// Create a Redux store holding the state of your app.
export default function configureStore(reloadedState) {
  return createStore(
    rootReducer,
    preloadedState
  )
}