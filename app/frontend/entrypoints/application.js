import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import { registerControllers } from 'stimulus-vite-helpers'

const application = Application.start()
application.debug = false

const regularControllers = import.meta.glob('./../controllers/**/*_controller.js', { eager: true })
let componentControllers = import.meta.glob('./../../components/**/*_controller.js', { eager: true })
componentControllers = Object.entries(componentControllers).reduce((acc, [path, module]) => {
  // remove the full path to the file, leave just the file name
  const fileName = path.split('/').pop()
  acc[fileName] = module
  return acc
}, {})
registerControllers(application, { ...regularControllers, ...componentControllers })

window.Stimulus = application
