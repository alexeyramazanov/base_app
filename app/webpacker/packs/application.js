// Support component names relative to this directory:
const componentRequireContext = require.context('components', true);

const ReactRailsUJS = require('react_ujs');
ReactRailsUJS.useContext(componentRequireContext);

// https://github.com/rails/webpacker/issues/1207
import Rails from 'rails-ujs';
Rails.start();

import * as ActiveStorage from 'activestorage';
ActiveStorage.start();

import ActionCable from 'actioncable';
window.Cable = ActionCable.createConsumer();

import 'jquery/dist/jquery';

import 'popper.js/dist/umd/popper';
import 'bootstrap/dist/js/bootstrap';

import '@fortawesome/fontawesome-free/js/all';

import './stylesheets.scss';
import './images'

import '../src/javascripts/common';
