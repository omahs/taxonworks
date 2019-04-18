import { CreateCollectionObject, UpdateCollectionObject } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'

export default function ({ commit, state }, co) {
  return new Promise((resolve, reject) => {
    let collection_object = co
    collection_object.collecting_event_id = state.collection_event.id
    if(collection_object.id) {
      UpdateCollectionObject(collection_object).then(response => {
        return resolve(response)
      }, (response) => {
        return reject(response)
      })
    }
    else {
      CreateCollectionObject(collection_object).then(response => {
        commit(MutationNames.SetSubsequentialUses, (state.subsequentialUses + 1))
        return resolve(response)
      }, (response) => {
        return reject(response)
      })
    }
  })
}