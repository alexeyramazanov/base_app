import { Controller } from "@hotwired/stimulus";

import { createCable } from "~/utils/cable";
import { isTurboPreview } from "~/utils/turbo.js";
import { ChatChannel } from "~/channels/chat_channel";

// It is possible that some messages could be lost during page load,
// this is known and is out of the scope of this example
export default class extends Controller {
  static targets = ['status', 'messages', 'input', 'submit']
  static values = { room: String }

  connect() {
    // do not run the code below if we are previewing cached version
    if (isTurboPreview()) return;

    const cable = createCable();

    this.channel = new ChatChannel({ room: this.roomValue });
    this.channel.on('connect', () => this.onConnect());
    this.channel.on('disconnect', () => this.onDisconnect());
    this.channel.on('message', (data) => this.onMessage(data));

    cable.subscribe(this.channel);

    this.listenToWindowResize();
    this.scrollChat();
    this.resizeChatWindow();
  }

  // do not add `isTurboPreview` check here as it will skip the disconnect code on page switch
  // because `isTurboPreview` becomes true before calling `disconnect`
  disconnect() {
    if (this.channel) {
      this.channel.disconnect();
      delete this.channel;
    }
  }

  onConnect() {
    this.statusTarget.classList.add('text-green-500');
    this.statusTarget.classList.remove('text-red-300');

    this.inputTarget.disabled = false;
    this.submitTarget.disabled = false;
  }

  onDisconnect() {
    this.inputTarget.disabled = true;
    this.submitTarget.disabled = true;

    this.statusTarget.classList.add('text-red-300');
    this.statusTarget.classList.remove('text-green-500');
  }

  onMessage(data) {
    switch(data.action) {
      case 'newMessage':
        this.onNewMessage(data);
        break;
    }
  }

  onNewMessage(data) {
    this.messagesTarget.insertAdjacentHTML('beforeend', data.html);
    this.scrollChat();
  }

  sendMessage(event) {
    event.preventDefault();

    const message = this.inputTarget.value.trim();
    this.inputTarget.value = '';

    if (!message) return;

    this.channel.perform('speak', { message });
  }

  listenToWindowResize() {
    window.addEventListener('resize', () => {
      this.resizeChatWindow();
    })
  }

  resizeChatWindow() {
    const messagesContainerHeight = document.getElementById('messages_container').clientHeight;
    const inputContainerHeight = document.getElementById('input_container').offsetHeight;

    this.messagesTarget.style.height = `${messagesContainerHeight - inputContainerHeight}px`;
  }

  scrollChat() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
  }
}
