/* eslint-disable no-undef */

import { Application } from '@hotwired/stimulus'

// Stimulus - Spree Controllers
import accordionController from './accordion_controller'
import FormDisabledController from './form/disabled_controller'
import FormValidationController from './form/validation_controller'

// Stimulus - Setup
window.Stimulus = Application.start()

Stimulus.register('accordion', accordionController)
Stimulus.register('input--disable-enable', FormDisabledController)
Stimulus.register('form--validation', FormValidationController)
