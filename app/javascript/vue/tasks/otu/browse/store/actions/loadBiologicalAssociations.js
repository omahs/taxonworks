import { MutationNames } from '../mutations/mutations'
import { BiologicalAssociation } from 'routes/endpoints'

export default ({ state, commit }, globalId) =>
  new Promise((resolve, reject) => {
    BiologicalAssociation.where({ any_global_id: globalId, extend: ['citations', 'object', 'subject', 'biological_relationship'] }).then(response => {
      commit(MutationNames.SetBiologicalAssociations, state.biologicalAssociations.concat(response.body))
      resolve(response)
    }, error => {
      reject(error)
    })
  })
