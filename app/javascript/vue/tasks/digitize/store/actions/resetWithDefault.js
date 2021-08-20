import ActionNames from './actionNames'

export default ({ dispatch, state }) => {
  const { locked } = state.settings

  dispatch(ActionNames.NewCollectionEvent)
  dispatch(ActionNames.NewCollectionObject)
  dispatch(ActionNames.NewTypeMaterial)
  dispatch(ActionNames.NewIdentifier)
  dispatch(ActionNames.NewTaxonDetermination)
  dispatch(ActionNames.NewLabel)

  state.collection_objects = []
  state.container = undefined
  state.containerItems = []
  state.depictions = []
  state.determinations = []
  state.georeferences = []
  state.identifiers = []
  state.materialTypes = []
  state.preparation_type_id = undefined
  state.taxon_determinations = []
  state.biologicalAssociations = locked.biologicalAssociations
    ? state.biologicalAssociations.map(item => ({...item, id: undefined, global_id: undefined }))
    : []
}
