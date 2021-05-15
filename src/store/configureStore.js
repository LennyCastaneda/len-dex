import { createStore } from 'redux'
import rootReducer from "./reducers";

// Create a Redux store holding the state of your app.
export default function configureStore() {
  return createStore(
    rootReducer
  )
}