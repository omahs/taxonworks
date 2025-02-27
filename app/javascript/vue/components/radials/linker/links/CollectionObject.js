import {
  TASK_COLLECTION_OBJECT_MATCH,
  TASK_COLLECTION_OBJECT_TABLE
} from '../constants/links'

export const CollectionObject = {
  all: [TASK_COLLECTION_OBJECT_MATCH, TASK_COLLECTION_OBJECT_TABLE],
  ids: [TASK_COLLECTION_OBJECT_MATCH, TASK_COLLECTION_OBJECT_TABLE]
  /*   per: [
    {
      label: 'By collecting event',
      link: '/tasks/collection_objects/filter',
      params: ['collecting_event_id']
    },
    {
      label: 'By verbatim locality',
      link: '/tasks/collection_objects/filter',
      params: ['verbatim_locality']
    },
    {
      label: 'By OTU',
      link: '/tasks/collection_objects/filter',
      params: ['otu_id']
    },
    {
      label: 'By taxon name',
      link: '/tasks/collection_objects/filter',
      params: ['ancestor_id']
    },
    {
      label: 'Images',
      link: '/tasks/images/filter',
      params: ['collection_object_id']
    },
    {
      label: 'Images by taxon name',
      link: '/tasks/images/filter',
      params: ['taxon_name_id']
    },
    {
      label: 'By geographic area',
      link: '/tasks/collection_objects/filter',
      params: ['geographic_area_id']
    }
  ] */
}
