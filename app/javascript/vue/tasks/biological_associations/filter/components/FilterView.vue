<template>
  <FacetTaxonName
    coverage
    relation
    mode
    v-model="params"
  />
  <FacetGeographic v-model="params" />
  <FacetWKT v-model="params" />
  <FacetBiologicalRelationship v-model="params" />
  <FacetBiologicalProperty v-model="params" />
  <FacetOtu
    v-model="params"
    target="BiologicalAssociation"
  />
  <FacetCollectionObject v-model="params" />
  <FacetCollectingEvent v-model="params" />
  <FacetNotes v-model="params" />
  <FacetIdentifier v-model="params" />
  <FacetTags
    v-model="params"
    target="CollectionObject"
  />
  <FacetUsers v-model="params" />
  <FacetWith
    :options="OBJECT_TYPE_OPTIONS"
    title="Object type"
    param="object_type"
    v-model="params"
  />
  <FacetWith
    :options="OBJECT_TYPE_OPTIONS"
    title="Subject type"
    param="subject_type"
    v-model="params"
  />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import FacetGeographic from '@/components/Filter/Facets/shared/FacetGeographic.vue'
import FacetWKT from '@/components/Filter/Facets/Otu/FacetWKT.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetUsers.vue'
import FacetIdentifier from '@/components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetBiologicalRelationship from '@/components/Filter/Facets/BiologicalAssociation/FacetBiologicalRelationship.vue'
import FacetTaxonName from '@/components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import FacetCollectionObject from '@/components/Filter/Facets/CollectionObject/FacetCollectionObject.vue'
import FacetCollectingEvent from './Facet/FacetCollectingEvent.vue'
import FacetBiologicalProperty from '@/components/Filter/Facets/BiologicalAssociation/FacetBiologicalProperty.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import { OTU, COLLECTION_OBJECT } from '@/constants/index.js'
import { computed } from 'vue'

const WITH_PARAMS = [
  'citations',
  'data_depictions',
  'depictions',
  'notes',
  'origin_citation',
  'tags'
]

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const OBJECT_TYPE_OPTIONS = [
  {
    label: 'Both',
    value: undefined
  },
  {
    label: 'Collection object',
    value: COLLECTION_OBJECT
  },
  {
    label: 'OTU',
    value: OTU
  }
]

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
