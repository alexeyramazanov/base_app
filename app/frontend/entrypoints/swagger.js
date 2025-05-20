import { Application } from '@hotwired/stimulus'
import { registerControllers } from 'stimulus-vite-helpers'

const application = Application.start()
application.debug = false

const swaggerController = import.meta.glob('./../controllers/swagger_controller.js', { eager: true })
registerControllers(application, { ...swaggerController })

window.Stimulus = application
