/* eslint-disable no-undef */

import { Application } from '@hotwired/stimulus'

// Stimulus - Spree Controllers
import InputCardValidationController from './input/card_validation_controller'
import InputDisabledController from './input/disabled_controller'
import FormValidationController from './form/validation_controller'

// Stimulus - Setup
window.Stimulus = Application.start()

Stimulus.register('input--card-validation', InputCardValidationController)
Stimulus.register('input--disable-enable', InputDisabledController)
Stimulus.register('form--validation', FormValidationController)
