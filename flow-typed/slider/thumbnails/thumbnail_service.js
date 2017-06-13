// @flow

type ThumbnailServicePreviewContentType =
  | string
  | { html: string, callback: (container: HTMLElement) => void };

interface ThumbnailService {
  constructor(url: string): void,
  getPreviewContent(): Promise<ThumbnailServicePreviewContentType>,
  getStorageId(): string,
  getThumbnailUrl(): Promise<string>
}
