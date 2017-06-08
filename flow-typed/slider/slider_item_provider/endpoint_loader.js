// @flow

interface EndpointLoader {
  getObjectsCountInOneSlide(): number,
  getMinimumSlidesPerPageCount(): number,
  getEndpointUrl(page: number, perPage: number, since: ?number): string,
  buildPlaceholderElement(): HTMLElement,
  populatePlaceholderElement(item: SliderItemType, data: any): void,
  parseTotalSlidesCountResponse(data: any): Promise<number>,
  parseEndpointData(data: any): any,
  afterLoadedCallback(item: HTMLElement): void
}
