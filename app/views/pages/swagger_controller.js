import {Controller} from '@hotwired/stimulus';
import SwaggerUI from 'swagger-ui';

export default class extends Controller {
  connect() {
    SwaggerUI({
      url: window.location.origin + '/public_api/swagger_doc.json',
      dom_id: '#swagger',
      deepLinking: true,
      tryItOutEnabled: true,
      defaultModelsExpandDepth: 5,
      defaultModelExpandDepth: 5
    })
  }
}
