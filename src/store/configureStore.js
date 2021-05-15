import { createStore } from 'redux'
import rootReducer from "./reducers";

// Create a Redux store holding the state of your app.
const store = createStore(
  rootReducer
)

export default function configureStore() {
  return store
}