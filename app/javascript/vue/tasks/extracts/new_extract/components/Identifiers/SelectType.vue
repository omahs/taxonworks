<template>
  <fieldset>
    <legend>Type</legend>
    <switch-component
      class="margin-small-bottom"
      v-model="tabList"
      :options="tabs"
    />
    <ul
      v-if="tabList"
      class="no_bullets capitalize"
    >
      <li
        v-for="(item, key) in list[tabList]"
        :key="key"
      >
        <label>
          <input
            v-model="typeSelected"
            :value="key"
            type="radio"
          />
          {{ item.label }}
        </label>
      </li>
    </ul>
  </fieldset>
</template>

<script>
import SwitchComponent from '@/components/switch'

export default {
  components: { SwitchComponent },

  props: {
    list: {
      type: Object,
      required: true
    },

    modelValue: {
      type: String,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  data() {
    return {
      tabList: 'common'
    }
  },

  computed: {
    tabs() {
      return Object.keys(this.list)
    },

    typeSelected: {
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
