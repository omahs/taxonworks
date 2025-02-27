<template>
  <div>
    <h2>Match people</h2>
    <p v-if="selectedPerson">{{ matchList.length }} matches found</p>
    <div>
      <autocomplete
        url="/people/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a person..."
        clear-after
        @get-item="addToList"
      />
      <table class="full_width">
        <thead>
          <tr>
            <th>
              <input
                v-model="selectAll"
                type="checkbox"
              />
            </th>
            <th>Cached</th>
            <th>Lived</th>
            <th>Active</th>
            <th>Used</th>
            <th>Roles</th>
          </tr>
        </thead>
        <tbody>
          <template
            v-for="person in matchList"
            :key="person.id"
          >
            <tr>
              <td>
                <input
                  type="checkbox"
                  :value="person"
                  :disabled="isSelectedPerson(person.id)"
                  v-model="selectedMergePerson"
                />
              </td>
              <td>{{ person.cached }}</td>
              <td>
                <span
                  class="feedback feedback-secondary feedback-thin line-nowrap"
                >
                  {{ yearValue(person.year_born) }} -
                  {{ yearValue(person.year_died) }}
                </span>
              </td>
              <td>
                <span
                  class="feedback feedback-secondary feedback-thin line-nowrap"
                >
                  {{ yearValue(person.year_active_start) }} -
                  {{ yearValue(person.year_active_end) }}
                </span>
              </td>
              <td>
                <span class="feedback feedback-thin feedback-primary">
                  {{ person.roles ? person.roles.length : '?' }}
                </span>
              </td>
              <td>{{ getRoles(person) }}</td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import Autocomplete from '@/components/ui/Autocomplete'
import getRoles from '../utils/getRoles.js'

export default {
  components: { Autocomplete },

  computed: {
    selectedPerson() {
      return this.$store.getters[GetterNames.GetSelectedPerson]
    },

    matchList: {
      get() {
        return this.$store.getters[GetterNames.GetMatchPeople]
      },
      set(value) {
        this.$store.commit(MutationNames.SetMatchPeople, value)
      }
    },

    selectedMergePerson: {
      get() {
        return this.$store.getters[GetterNames.GetMergePeople]
      },

      set(value) {
        this.$store.commit(MutationNames.SetMergePeople, value)
      }
    },

    selectAll: {
      get() {
        return (
          this.matchList.length &&
          this.selectedMergePerson.length === this.matchList.length
        )
      },

      set(value) {
        this.selectedMergePerson = value
          ? this.matchList.filter((item) => item.id !== this.selectedPerson.id)
          : []
      }
    }
  },

  methods: {
    addToList(person) {
      this.$store.dispatch(ActionNames.AddMatchPerson, person)
    },

    getRoles,

    yearValue(value) {
      return value || '?'
    },

    isSelectedPerson(id) {
      return this.selectedPerson.id === id
    }
  }
}
</script>

<style scoped>
.list-search {
  max-height: 500px;
  overflow-y: scroll;
}
</style>
