// Support component names relative to this directory:
const componentRequireContext = require.context('components', true);

const ReactRailsUJS = require('react_ujs');
ReactRailsUJS.useContext(componentRequireContext);

require('@rails/ujs').start();

require('@rails/activestorage').start();

require('../src/javascripts/channels');

import 'jquery/dist/jquery';

import 'popper.js/dist/umd/popper';
import 'bootstrap/dist/js/bootstrap';

import '@fortawesome/fontawesome-free/js/all';

import './stylesheets.scss';
import './images'

import '../src/javascripts/common';
