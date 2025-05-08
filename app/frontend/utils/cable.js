import { createCable as create } from "@anycable/web";

let instance;

export const createCable = () => {
  if (!instance) {
    instance = create({
      protocol: 'actioncable-v1-ext-json'
    });
  }

  return instance;
}
