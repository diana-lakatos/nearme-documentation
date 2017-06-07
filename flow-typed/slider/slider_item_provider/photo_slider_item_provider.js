// @flow
type PhotoEndpointResponseItemType = {
  image: {
    image_original_width: number,
    image_original_height: number,
    large: string,
    thumb: string
  },
  creator: {
    name: string,
    profile_path: string,
    avatar: {
      url: string
    }
  }
};

type PhotoEndpointResponseType = {
  photos: {
    total_entries: number,
    items: Array<PhotoEndpointResponseItemType>
  }
};
