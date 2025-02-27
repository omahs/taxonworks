<template>
  <div>
    <div class="radial-annotator">
      <modal
        v-if="display"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <span class="flex-separate middle">
            <span v-html="title" />
            <b
              v-if="metadata"
              class="margin-large-left"
            >
              {{ metadata.object_type }}
            </b>
          </span>
        </template>
        <template #body>
          <div class="flex-separate">
            <spinner v-if="!menuCreated" />
            <div class="radial-annotator-menu">
              <div>
                <radial-menu
                  v-if="menuCreated"
                  :options="menuOptions"
                  @onClick="selectComponent"
                />
              </div>
            </div>
            <div
              class="radial-annotator-template panel"
              v-if="currentAnnotator"
            >
              <h2 class="capitalize view-title">
                {{ currentAnnotator.replace('_', ' ') }}
              </h2>
              <component
                v-if="metadataLoaded"
                class="radial-annotator-container"
                :is="
                  currentAnnotator ? currentAnnotator + 'Annotator' : undefined
                "
                :type="currentAnnotator"
                :url="url"
                :metadata="metadata"
                :global-id="globalId"
                :object-type="metadata.object_type"
                @updateCount="setTotal"
              />
            </div>
          </div>
        </template>
      </modal>

      <VBtn
        v-if="showBottom"
        circle
        color="radial"
        :title="buttonTitle"
        :class="[pulse ? 'pulse-blue' : '']"
        :disabled="disabled"
        @contextmenu.prevent="loadContextMenu"
        @click="displayAnnotator()"
      >
        <VIcon
          :title="buttonTitle"
          name="radialAnnotator"
          x-small
        />
      </VBtn>
      <div
        v-if="metadataCount && showCount"
        class="circle-count button-submit middle"
      >
        <span class="citation-count-text">{{ metadataCount }}</span>
      </div>
      <context-menu
        :metadata="metadata"
        :global-id="globalId"
        v-model="showContextMenu"
        v-if="showContextMenu"
      />
    </div>
  </div>
</template>
<script>
import RadialMenu from '@/components/radials/RadialMenu.vue'
import modal from '@/components/ui/Modal.vue'
import spinner from '@/components/spinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

import CRUD from './request/crud'

import confidencesAnnotator from './components/confidence/confidence_annotator.vue'
import depictionsAnnotator from './components/depictions/depiction_annotator.vue'
import documentationAnnotator from './components/documentation_annotator.vue'
import identifiersAnnotator from './components/identifier/identifier_annotator.vue'
import tagsAnnotator from './components/tag_annotator.vue'
import notesAnnotator from './components/note_annotator.vue'
import data_attributesAnnotator from './components/data_attribute_annotator.vue'
import alternate_valuesAnnotator from './components/alternate_value_annotator.vue'
import citationsAnnotator from './components/citations/citation_annotator.vue'
import protocol_relationshipsAnnotator from './components/protocol_annotator.vue'
import attributionAnnotator from './components/attribution/main.vue'
import verifiersAnnotator from './components/verifiers/Verifiers.vue'

import ContextMenu from './components/contextMenu'
import Icons from './images/icons.js'
import shortcutsMixin from '../mixins/shortcuts'
import { Tag } from '@/routes/endpoints'
import { RadialAnnotatorEventEmitter } from '@/utils/index.js'

const MIDDLE_RADIAL_BUTTON = 'circleButton'

export default {
  mixins: [CRUD, shortcutsMixin],

  name: 'RadialAnnotator',

  components: {
    RadialMenu,
    modal,
    spinner,
    notesAnnotator,
    citationsAnnotator,
    confidencesAnnotator,
    depictionsAnnotator,
    data_attributesAnnotator,
    documentationAnnotator,
    alternate_valuesAnnotator,
    identifiersAnnotator,
    tagsAnnotator,
    protocol_relationshipsAnnotator,
    attributionAnnotator,
    verifiersAnnotator,
    ContextMenu,
    VBtn,
    VIcon
  },

  emits: ['close'],

  props: {
    reload: {
      type: Boolean,
      default: false
    },

    globalId: {
      type: String,
      required: true
    },

    showBottom: {
      type: Boolean,
      default: true
    },

    buttonClass: {
      type: String,
      default: 'btn-radial-annotator'
    },

    buttonTitle: {
      type: String,
      default: 'Radial annotator'
    },

    showCount: {
      type: Boolean,
      default: false
    },

    defaultView: {
      type: String,
      default: undefined
    },

    components: {
      type: Object,
      default: () => ({})
    },

    type: {
      type: String,
      default: 'annotations'
    },

    pulse: {
      type: Boolean,
      default: false
    },

    disabled: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      currentAnnotator: undefined,
      display: false,
      url: undefined,
      globalIdSaved: undefined,
      metadata: undefined,
      title: 'Radial annotator',
      defaultTag: undefined,
      showContextMenu: false,
      listenerId: undefined
    }
  },

  computed: {
    metadataLoaded() {
      return (
        this.globalId === this.globalIdSaved && this.menuCreated && !this.reload
      )
    },

    menuCreated() {
      return this.metadata?.endpoints
    },

    menuOptions() {
      const endpoints = this.metadata.endpoints || {}

      const slices = Object.entries(endpoints).map(
        ([annotator, { total }]) => ({
          name: annotator,
          label: (
            annotator.charAt(0).toUpperCase() + annotator.slice(1)
          ).replace('_', ' '),
          innerPosition: 1.7,
          svgAttributes: {
            class:
              this.currentAnnotator === annotator ? 'slice active' : 'slice'
          },
          slices: total
            ? [
                {
                  label: total.toString(),
                  size: 26,
                  svgAttributes: {
                    class: 'slice-total'
                  }
                }
              ]
            : [],
          icon: Icons[annotator]
            ? {
                url: Icons[annotator],
                width: '20',
                height: '20'
              }
            : undefined
        })
      )

      return {
        width: 400,
        height: 400,
        sliceSize: 120,
        centerSize: 34,
        margin: 2,
        middleButton: this.middleButton,
        svgAttributes: {
          class: 'svg-radial-menu'
        },
        svgSliceAttributes: {
          fontSize: 11
        },
        slices
      }
    },

    metadataCount() {
      if (this.metadata) {
        let totalCounts = 0
        for (const key in this.metadata.endpoints) {
          const section = this.metadata.endpoints[key]
          if (typeof section === 'object') {
            totalCounts = totalCounts + Number(section.total)
          }
        }
        return totalCounts
      }
      return undefined
    },

    isTagged() {
      return !!this.defaultTag
    },

    middleButton() {
      return {
        name: MIDDLE_RADIAL_BUTTON,
        radius: 30,
        icon: {
          url: Icons.tags,
          width: '20',
          height: '20'
        },
        svgAttributes: {
          fontSize: 11,
          fill: this.getDefault()
            ? this.isTagged
              ? '#F44336'
              : '#9ccc65'
            : '#CACACA',
          style: 'cursor: pointer'
        },
        backgroundHover: this.getDefault()
          ? this.isTagged
            ? '#CE3430'
            : '#81a553'
          : '#CACACA'
      }
    }
  },

  watch: {
    metadataLoaded() {
      if (this.defaultView) {
        this.currentAnnotator = this.isComponentExist(this.defaultView)
      }
    },

    display(newVal) {
      if (newVal && this.metadataLoaded) {
        this.currentAnnotator = this.isComponentExist(this.defaultView)
      }
    }
  },

  created() {
    if (this.showCount) {
      this.loadMetadata()
    }

    RadialAnnotatorEventEmitter.on('reset', this.resetAnnotator)
  },

  unmounted() {
    RadialAnnotatorEventEmitter.removeListener('reset', this.resetAnnotator)
  },

  methods: {
    isComponentExist(componentName) {
      return this.$options.components[`${componentName}Annotator`]
        ? componentName
        : undefined
    },

    loadContextMenu() {
      this.showContextMenu = true
      this.loadMetadata()
    },

    getDefault() {
      const defaultTag = document.querySelector(
        '[data-pinboard-section="Keywords"] [data-insert="true"]'
      )
      return defaultTag
        ? defaultTag.getAttribute('data-pinboard-object-id')
        : undefined
    },

    alreadyTagged() {
      const keyId = this.getDefault()
      if (!keyId) return

      const params = {
        global_id: this.globalId,
        keyword_id: keyId
      }

      Tag.exists(params).then(({ body }) => {
        this.defaultTag = body
      })
    },

    selectComponent({ name }) {
      if (name === MIDDLE_RADIAL_BUTTON) {
        if (this.getDefault()) {
          this.isTagged ? this.deleteTag() : this.createTag()
        }
      } else {
        this.currentAnnotator = name
      }
    },

    closeModal() {
      this.display = false
      this.$emit('close')
      this.eventClose()
      this.removeListener()
    },

    async displayAnnotator() {
      this.display = true
      await this.loadMetadata()
      this.alreadyTagged()
      this.eventOpen()
      this.setShortcutsEvent()
    },

    async loadMetadata() {
      if (
        this.globalId === this.globalIdSaved &&
        this.menuCreated &&
        !this.reload
      )
        return
      this.globalIdSaved = this.globalId

      return this.getList(
        `/${this.type}/${encodeURIComponent(this.globalId)}/metadata`
      ).then(({ body }) => {
        this.metadata = body
        this.title = body.object_tag
        this.url = body.url
      })
    },

    setTotal(total) {
      const sliceMetadata = this.metadata.endpoints[this.currentAnnotator]

      if (total !== sliceMetadata.total) {
        sliceMetadata.total = total
        this.eventUpdate()
      }
    },

    eventOpen() {
      const event = new CustomEvent('radialAnnotator:open', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },

    eventUpdate() {
      const event = new CustomEvent('radialAnnotator:update', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },

    eventClose() {
      const event = new CustomEvent('radialAnnotator:close', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },

    createTag() {
      const tag = {
        keyword_id: this.getDefault(),
        annotated_global_entity: this.globalId
      }

      Tag.create({ tag }).then((response) => {
        this.defaultTag = response.body
        TW.workbench.alert.create(
          'Tag item was successfully created.',
          'notice'
        )
      })
    },

    deleteTag() {
      Tag.destroy(this.defaultTag.id).then((_) => {
        this.defaultTag = undefined
        TW.workbench.alert.create(
          'Tag item was successfully destroyed.',
          'notice'
        )
      })
    },

    resetAnnotator() {
      this.metadata = undefined
      this.globalIdSaved = undefined
    }
  }
}
</script>
<style lang="scss">
.svg-radial-menu {
  text-anchor: middle;

  g:hover {
    cursor: pointer;
    opacity: 0.9;
  }

  path.slice {
    fill: #ffffff;
  }

  path.active {
    fill: #8f8f8f;
  }

  path.slice-total {
    fill: #006ebf;
  }

  tspan.slice-total {
    fill: #ffffff;
  }
}

.radial-annotator {
  position: relative;
  width: initial;
  color: initial;

  .modal-close {
    top: 30px;
    right: 20px;
  }

  .modal-mask {
    background-color: rgba(0, 0, 0, 0.7);
  }

  .modal-container {
    min-width: 1024px;
    width: 1200px;
    overflow-y: hidden;
  }

  .radial-annotator-template {
    background: #ffffff;
    padding: 1em;
    width: 100%;
    max-width: 100%;
    height: 80vh;
    overflow-y: auto;
  }

  .radial-annotator-container {
    display: flex;
    height: 100%;
    flex-direction: column;
    overflow-y: scroll;
    position: relative;
  }

  .radial-annotator-menu {
    width: 700px;
    height: 90vh;
  }

  .annotator-buttons-list {
    overflow-y: scroll;
  }

  .save-annotator-button {
    width: 100px;
  }

  .circle-count {
    bottom: -6px;
  }
}

.tag_button {
  padding-left: 12px;
  padding-right: 8px;
  width: auto !important;
  min-width: auto !important;
  cursor: pointer;
  margin: 2px;
  border: none;
  border-top-left-radius: 15px;
  border-bottom-left-radius: 15px;
}
</style>
