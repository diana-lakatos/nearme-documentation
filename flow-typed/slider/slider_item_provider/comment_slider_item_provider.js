// @flow
type CommentEndpointResponseItemType = {
  id: number,
  body: string,
  url: string,
  show_path: string,
  creator: {
    id: number,
    name: string,
    profile_path: string,
    avatar: {
      url: string
    }
  },
  commentable: {
    id: number,
    url: string,
    name: string
  },
  created_at: string,
  activity_feed_images: Array<{
    filename: string,
    image_original_height: number,
    image_original_width: number,
    thumb: string,
    full: string
  }>
};

type CommentEndpointResponseType = {
  comments: {
    total_entries: number,
    has_next_page: boolean,
    total_pages: number,
    items: Array<CommentEndpointResponseItemType>
  }
};
