<template>
  <modal-component
    @close="$emit('close', true)"
    :containerStyle="{ 'overflow-y': 'scroll', 'max-height': '80vh' }"
    class="full_width"
  >
    <template #header>
      <h3>Create a source from a verbatim citation or DOI</h3>
    </template>
    <template #body>
      <spinner-component
        v-if="searching"
        :full-screen="true"
        legend="Searching..."
      />
      <ul>
        <li>Submit either a DOI or full citation.</li>
        <li>
          DOIs should be in the form of
          <pre>https://doi.org/10.1145/3274442</pre>
          or
          <pre>10.1145/3274442</pre>
          or
          <pre>doi:10.1145/3274442</pre>
        </li>
        <li>
          The query will be resolved against
          <a href="https://www.crossref.org/">CrossRef</a>.
        </li>
        <li>
          If there is a hit, then you will be given the option to import the
          parsed citation. This is the BibTeX format.
        </li>
        <li>
          If there is no hit, you have the option to import the record as a
          single field. This is the Verbatim format.
        </li>
        <li>
          The created source is automatically added to the current project.
        </li>
        <li>
          <em
            >Not all hits are correct! Check that the result matches the
            query.</em
          >
        </li>
      </ul>
      <textarea
        ref="textareaRef"
        class="full_width"
        v-model="citation"
        placeholder="DOI or citation to find..."
      />
    </template>
    <template #footer>
      <div class="flex-separate separate-top">
        <button
          @click="getSource"
          :disabled="!citation.length"
          class="button normal-input button-default"
          type="button"
        >
          Find
        </button>
        <button
          v-if="!found"
          @click="setVerbatim"
          class="button normal-input button-default"
          type="button"
        >
          Set as verbatim
        </button>
      </div>
    </template>
  </modal-component>
</template>

<script>
import AjaxCall from '@/helpers/ajaxCall'
import SpinnerComponent from '@/components/spinner'
import ModalComponent from '@/components/ui/Modal'
import { MutationNames } from '../store/mutations/mutations'
import { Serial } from '@/routes/endpoints'
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },

  emits: ['close'],

  data() {
    return {
      citation: '',
      searching: false,
      found: true
    }
  },

  mounted() {
    this.$refs.textareaRef.focus()
  },

  methods: {
    getSource() {
      this.searching = true
      this.$store.dispatch(ActionNames.ResetSource)
      AjaxCall(
        'get',
        `/tasks/sources/new_source/crossref_preview.json?citation=${this.citation}`
      )
        .then((response) => {
          if (response.body.title) {
            this.$store.dispatch(ActionNames.ResetSource)
            response.body.roles_attributes = []
            this.$store.commit(MutationNames.SetSource, response.body)

            if (response.body.journal) {
              Serial.where({ name: response.body.journal }).then((response) => {
                if (response.body.length) {
                  this.$store.commit(
                    MutationNames.SetSerialId,
                    response.body[0].id
                  )
                }
              })
            }
            this.$emit('close', true)
            TW.workbench.alert.create('Found! (please check).', 'notice')
          } else {
            this.found = false
            TW.workbench.alert.create(
              'Nothing found or the source already exist.',
              'error'
            )
          }
        })
        .finally(() => {
          this.searching = false
        })
    },

    setVerbatim() {
      this.$store.commit(MutationNames.SetSource, {
        type: 'Source::Verbatim',
        verbatim: this.citation
      })
      this.$emit('close', true)
    }
  }
}
</script>

<style scoped>
:deep(.modal-container) {
  width: 500px;
}
textarea {
  height: 100px;
}
</style>
