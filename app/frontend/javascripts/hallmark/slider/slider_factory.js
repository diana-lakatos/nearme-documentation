// @flow

import Slider from './slider';
import EndpointSliderItemProvider from './slider_item_providers/endpoint_slider_item_provider';

class SliderFactory {
  static create(el: HTMLElement): Promise<Slider> {
    return new Promise(resolve => {
      if (el.hasAttribute('data-comment-slider')) {
        require.ensure('./slider_item_providers/comment_endpoint_loader', require => {
          const CommentEndpointLoader = require('./slider_item_providers/comment_endpoint_loader');
          let provider = new EndpointSliderItemProvider(el, new CommentEndpointLoader());
          resolve(new Slider(el, provider));
        });
        return;
      }

      if (el.hasAttribute('data-photo-slider')) {
        require.ensure('./slider_item_providers/photo_endpoint_loader', require => {
          const PhotoEndpointLoader = require('./slider_item_providers/photo_endpoint_loader');
          let provider = new EndpointSliderItemProvider(el, new PhotoEndpointLoader(el));
          resolve(new Slider(el, provider));
        });
        return;
      }

      if (el.hasAttribute('data-transactable-slider')) {
        require.ensure('./slider_item_providers/transactable_endpoint_loader', require => {
          const TransactableEndpointLoader = require('./slider_item_providers/transactable_endpoint_loader');
          let provider = new EndpointSliderItemProvider(el, new TransactableEndpointLoader());
          resolve(new Slider(el, provider));
        });
        return;
      }

      if (el.hasAttribute('data-video-slider')) {
        require.ensure('./slider_item_providers/video_slider_item_provider', require => {
          const VideoSliderItemProvider = require('./slider_item_providers/video_slider_item_provider');
          let provider = new VideoSliderItemProvider(el);
          resolve(new Slider(el, provider));
        });
        return;
      }

      throw new Error('Slider is using an unsupported item provider');
    });
  }
}

module.exports = SliderFactory;
