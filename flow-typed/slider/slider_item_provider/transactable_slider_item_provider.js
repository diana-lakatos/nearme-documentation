// @flow
type TransactableEndpointResponseItemType = {
  id: number,
  title: string,
  cover_photo: {
    url: string
  },
  show_path: string,
  creator: {
    id: number,
    name: string,
    profile_path: string,
    avatar: {
      url: string
    }
  },
  comments: {
    count: number
  },
  last_comment: {
    items: Array<{
      created_at: string
    }>
  },
  followers: {
    total_entries: number
  }
};

type TransactableEndpointResponseType = {
  projects: {
    total_entries: number,
    items: Array<TransactableEndpointResponseItemType>
  }
};
