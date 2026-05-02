import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import { registerControllers } from 'stimulus-vite-helpers'

const application = Application.start()
application.debug = false

const regularControllers = import.meta.glob('./../controllers/**/*_controller.js', { eager: true })
let componentControllers = import.meta.glob('./../../view_components/**/index.js', { eager: true })
componentControllers = Object.entries(componentControllers).reduce((acc, [path, module]) => {
  // get component name, for example "shared_ui--dropdown"
  let name = path
    .match(/..\/..\/view_components\/(.+)\/index\.js$/)[1]
    .replaceAll("/", "--")
  acc[`${name}_component_controller.js`] = module
  return acc
}, {})
registerControllers(application, { ...regularControllers, ...componentControllers })

window.Stimulus = application
