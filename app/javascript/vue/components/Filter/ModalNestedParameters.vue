<template>
  <VModal
    v-if="isModalVisible"
    @close="isModalVisible = false"
    :container-style="{ width: '600px' }"
  >
    <template #header>
      <h3>Nested parameters</h3>
    </template>
    <template #body>
      <ol>
        <li
          v-for="{ params, objectType } in nestedLevels"
          :key="params"
        >
          <div class="flex-separate middle">
            <span>{{ objectType }} ({{ getTotalResult(params) }})</span>
            <VBtn
              class="middle"
              color="primary"
              medium
              @click="openFilterFor(objectType, Object.values(params)[0])"
            >
              Go
            </VBtn>
          </div>
          <pre
            class="break_words_pre"
            v-text="JSON.stringify(params, null, 2)"
          />
        </li>
      </ol>
    </template>
  </VModal>
  <VBtn
    class="middle"
    color="primary"
    medium
    :disabled="isEmpty"
    @click="isModalVisible = true"
  >
    <VIcon
      x-small
      :color="isEmpty ? 'currentColor' : 'warning'"
      name="attention"
    />
    <span class="margin-xsmall-left">History</span>
  </VBtn>
</template>

<script setup>
import { ref, computed } from 'vue'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { FILTER_ROUTES } from '@/routes/routes'
import { isDeepEqual } from '@/helpers/objects'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import qs from 'qs'

const props = defineProps({
  parameters: {
    type: Object,
    default: () => ({})
  }
})

const isModalVisible = ref(false)

const isEmpty = computed(() => !nestedLevels.value.length)

const nestedLevels = computed(() => {
  const levels = []
  let params = props.parameters
  let subLevel = true

  do {
    const keys = Object.keys(params)
    const queryParam = keys.find((item) => item.includes('_query'))

    if (queryParam) {
      params = params[queryParam]

      levels.push({
        objectType: getObjectTypeByQueryParam(queryParam),
        params: { [queryParam]: params }
      })
    } else {
      subLevel = false
    }
  } while (subLevel)

  return levels
})

function openFilterFor(objType, params) {
  const url = `${FILTER_ROUTES[objType]}?${qs.stringify(params)}`

  window.open(url, '_self')
}

function getObjectTypeByQueryParam(queryParam) {
  const [objectType] = Object.entries(QUERY_PARAM).find(
    ([_, key]) => queryParam === key
  )

  return objectType
}

function getTotalResult(params) {
  const total = JSON.parse(sessionStorage.getItem('totalQueries')) || []

  return total.find((item) => isDeepEqual(params, item.params))?.total || '??'
}
</script>
