/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

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