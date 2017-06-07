// @flow

interface EndpointLoader {
  getObjectsCountInOneSlide(): number,
  getDefaultItemsPerPageCount(): number,
  getMinimumItemsCount(): number,
  getEndpointUrl(since: number, page: number, perPage: number): string,
  buildPlaceholderElement(): HTMLElement,
  populatePlaceholderElement(item: SliderItemType, data: any): void,
  parseTotalEntriesResponse(data: any): Promise<number>,
  parseEndpointData(data: any): any,
  afterLoadedCallback(item: HTMLElement): void
}
