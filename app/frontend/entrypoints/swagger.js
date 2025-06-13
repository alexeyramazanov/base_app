import { Application } from '@hotwired/stimulus'
import { registerControllers } from 'stimulus-vite-helpers'

const application = Application.start()
application.debug = false

// https://github.com/swagger-api/swagger-ui/issues/8902
// swaggerController is stored outside regular controllers to allow vite to generate separate import chunks
// this significantly improves performance by having a small import chunk for the main application
let componentControllers = import.meta.glob('./../../views/pages/swagger_controller.js', { eager: true })
componentControllers = Object.entries(componentControllers).reduce((acc, [path, module]) => {
  // remove the full path to the file, leave just the file name
  const fileName = path.split('/').pop()
  acc[fileName] = module
  return acc
}, {})
registerControllers(application, componentControllers)

window.Stimulus = application
