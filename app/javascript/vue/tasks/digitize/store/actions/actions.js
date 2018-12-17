import ActionNames from './actionNames'
import getTaxon from './getTaxon'
import saveDigitalization from './saveDigitalization'
import saveIdentifier from './saveIdentifier'
import saveCollectionObject from './saveCollectionObject'
import saveCollectionEvent from './saveCollectionEvent'
import saveTypeMaterial from './saveTypeMaterial'
import saveDetermination from './saveDetermination'
import saveDeterminations from './saveDeterminations'
import saveContainerItem from './saveContainerItem'
import saveContainer from './saveContainer'
import removeCollectionObject from './removeCollectionObject'
import newCollectionObject from './newCollectionObject'
import saveLabel from './saveLabel'
import removeDepictionsByImageId from './removeDepictionsByImageId'
import removeTaxonDetermination from './removeTaxonDetermination'

const ActionFunctions = {
  [ActionNames.GetTaxon]: getTaxon,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveIdentifier]: saveIdentifier,
  [ActionNames.SaveCollectionObject]: saveCollectionObject,
  [ActionNames.SaveCollectionEvent]: saveCollectionEvent,
  [ActionNames.SaveTypeMaterial]: saveTypeMaterial,
  [ActionNames.SaveDetermination]: saveDetermination,
  [ActionNames.SaveDeterminations]: saveDeterminations,
  [ActionNames.SaveContainerItem]: saveContainerItem,
  [ActionNames.SaveContainer]: saveContainer,
  [ActionNames.RemoveCollectionObject]: removeCollectionObject,
  [ActionNames.NewCollectionObject]: newCollectionObject,
  [ActionNames.SaveLabel]: saveLabel,
  [ActionNames.RemoveDepictionsByImageId]: removeDepictionsByImageId,
  [ActionNames.RemoveTaxonDetermination]: removeTaxonDetermination
}

export { ActionNames, ActionFunctions }
