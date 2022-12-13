/* eslint-disable no-undef */

import { Application } from '@hotwired/stimulus'

// Stimulus - Spree Controllers
import accordionController from './accordion_controller'
import FormValidationController from './form/validation_controller'

// Stimulus - Setup
window.Stimulus = Application.start()

Stimulus.register('accordion', accordionController)
Stimulus.register('form--validation', FormValidationController)
