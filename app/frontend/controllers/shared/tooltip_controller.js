import { Controller } from '@hotwired/stimulus';
import { computePosition, autoUpdate, offset, shift, flip, arrow } from '@floating-ui/dom';

import '../../styles/shared/tooltip.css';

// based on https://floating-ui.com/docs/tutorial
export default class extends Controller {
  static values = {
    content: String,
    placement: { type: String, default: 'top' }
  }

  connect() {
    this.buildTooltip();
    this.setupEvents()
  }

  disconnect() {
    this.hide();
    this.cleanupEvents();
  }

  buildTooltip() {
    this.tooltipElement = document.createElement('div');
    this.tooltipElement.classList.add('tooltip');
    this.tooltipElement.setAttribute('role', 'tooltip');
    this.tooltipElement.textContent = this.contentValue;

    this.arrowElement = document.createElement('div');
    this.arrowElement.classList.add('tooltip-arrow');
    this.tooltipElement.appendChild(this.arrowElement);
  }

  setupEvents() {
    this.mouseEnterHandler = this.show.bind(this);
    this.mouseLeaveHandler = this.hide.bind(this);
    this.focusHandler = this.show.bind(this);
    this.blurHandler = this.hide.bind(this);

    this.element.addEventListener('mouseenter', this.mouseEnterHandler);
    this.element.addEventListener('mouseleave', this.mouseLeaveHandler);
    this.element.addEventListener('focus', this.focusHandler);
    this.element.addEventListener('blur', this.blurHandler);
  }

  cleanupEvents() {
    this.element.removeEventListener('mouseenter', this.mouseEnterHandler);
    this.element.removeEventListener('mouseleave', this.mouseLeaveHandler);
    this.element.removeEventListener('focus', this.focusHandler);
    this.element.removeEventListener('blur', this.blurHandler);
  }

  show() {
    document.body.appendChild(this.tooltipElement);

    this.tooltipElement.style.display = 'block';

    this.cleanup = autoUpdate(
      this.element,
      this.tooltipElement,
      this.updatePosition.bind(this)
    );
  }

  hide() {
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }

    this.tooltipElement.style.display = 'none';
    document.body.removeChild(this.tooltipElement);
  }

  updatePosition() {
    computePosition(
      this.element,
      this.tooltipElement,
      {
        placement: this.placementValue,
        middleware: [
          // order is important
          offset(8),
          flip(),
          shift({ padding: 5 }),
          arrow({ element: this.arrowElement })
        ]
      }
    ).then(({ x, y, placement, middlewareData }) => {
      Object.assign(this.tooltipElement.style, {
        left: `${x}px`,
        top: `${y}px`
      });

      const { x: arrowX, y: arrowY } = middlewareData.arrow;

      const staticSide = {
        top: 'bottom',
        right: 'left',
        bottom: 'top',
        left: 'right'
      }[placement.split('-')[0]];

      Object.assign(this.arrowElement.style, {
        left: arrowX != null ? `${arrowX}px` : '',
        top: arrowY != null ? `${arrowY}px` : '',
        right: '',
        bottom: '',
        [staticSide]: '-4px'
      });
    });
  }
}
