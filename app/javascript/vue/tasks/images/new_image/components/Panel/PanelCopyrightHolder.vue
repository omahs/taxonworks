<template>
  <BlockLayout>
    <template #header>
      <h3>Copyright Holder</h3>
    </template>
    <template #body>
      <div class="margin-large-bottom">
        <VSwitch
          class="separate-bottom"
          full-width
          :options="Object.values(OPTIONS)"
          v-model="view"
        />
        <RolePicker
          v-model="rolesAttributes"
          :role-type="ROLE_ATTRIBUTION_COPYRIGHT_HOLDER"
          :organization="view === OPTIONS.Organization"
        />
      </div>
      <div class="field label-above">
        <label> Year of copyright </label>
        <input
          type="number"
          v-model="year"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VSwitch from '@/components/switch'
import RolePicker from '@/components/role_picker'
import { ROLE_ATTRIBUTION_COPYRIGHT_HOLDER } from '@/constants'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'

const OPTIONS = {
  People: 'Someone else',
  Organization: 'An organization'
}

const store = useStore()

const rolesAttributes = computed({
  get: () => store.getters[GetterNames.GetPeople].copyrightHolder,
  set(value) {
    store.commit(MutationNames.SetCopyrightHolder, value)
  }
})

const year = computed({
  get: () => store.getters[GetterNames.GetYearCopyright],
  set(value) {
    store.commit(MutationNames.SetYearCopyright, value)
  }
})

const view = ref('Someone else')
</script>
