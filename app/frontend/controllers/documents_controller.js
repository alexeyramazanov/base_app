import { Controller } from '@hotwired/stimulus';
import Uppy from '@uppy/core';
import DragDrop from '@uppy/drag-drop';
import StatusBar from '@uppy/status-bar';
import AwsS3 from '@uppy/aws-s3';

import '@uppy/core/dist/style.css';
import '~/styles/documents/uppy_drag_drop.css';
import '~/styles/documents/uppy_status_bar.css';

export default class extends Controller {
  static targets = ['submitForm', 'submitFormInput']
  static values = { presignUrl: String }

  connect() {
    this.initializeUppy();
  }

  disconnect() {
    this.uppy.destroy();
  }

  initializeUppy() {
    this.uppy = new Uppy({
      autoProceed: true,
      restrictions: {
        maxNumberOfFiles: 1,
        maxFileSize: 10 * 1024 * 1024, // 10MB
        allowedFileTypes: ['image/jpg', 'image/jpeg', 'image/png']
      }
    })
      .use(DragDrop, {
        target: '#upload_dropzone',
        height: '100px'
      })
      .use(StatusBar, {
        target: '#status_bar',
        hideRetryButton: true,
        hidePauseResumeButton: true
      })
      .use(AwsS3, {
        endpoint: this.presignUrlValue,
        shouldUseMultipart: false
      });

    this.uppy
      .on('upload-start', (_file) => {
        const dragDropEl = document.querySelector('.uppy-DragDrop-container');
        dragDropEl.style.pointerEvents = 'none'; // disable while upload is in progress
      })
      .on('upload-success', (file, response) => {
        this.submitFormInputTarget.value = this.uploadedFileData(file, response);
        this.submitFormTarget.requestSubmit();
      })
  }

  uploadedFileData(file, _response) {
    const id = file.s3Multipart['key'].match(/^cache\/(.+)/)[1]; // object key without prefix
    const data = {
      id: id,
      storage: 'cache',
      metadata: {
        size:      file.size,
        filename:  file.name,
        mime_type: file.type,
      }
    };

    return JSON.stringify(data);
  }
}
