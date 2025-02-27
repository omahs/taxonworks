<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th class="word-keep-all line-nowrap">Georeference ID</th>
          <th class="word-keep-all">Shape</th>
          <th class="word-keep-all">Coordinates</th>
          <th class="word-keep-all line-nowrap">Error radius</th>
          <th class="word-keep-all">Type</th>
          <th class="word-keep-all">Date</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item"
        >
          <td>{{ item.id }}</td>
          <td class="word-keep-all">
            {{
              isTmpWkt(item) || isTempGeolocate(item)
                ? ''
                : getGeoJsonType(item)
            }}
          </td>
          <td>{{ getCoordinatesByType(item) }}</td>
          <td class="line-nowrap">
            <edit-in-place
              v-model="item.error_radius"
              @end="$emit('update', item)"
            />
          </td>
          <td class="word-keep-all">{{ item.type }}</td>
          <td>
            <div class="horizontal-left-content">
              <date-component
                v-model:day="item.day_georeferenced"
                v-model:month="item.month_georeferenced"
                v-model:year="item.year_georeferenced"
                placeholder
              />
              <v-btn
                color="update"
                medium
                @click="$emit('dateChanged', item)"
              >
                Update
              </v-btn>
            </div>
          </td>
          <td>
            <div class="vue-table-options gap-small">
              <radial-annotator
                v-if="item.global_id"
                :global-id="item.global_id"
              />
              <span
                v-if="destroy"
                class="circle-button btn-delete"
                @click="deleteItem(item)"
                >Remove
              </span>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import EditInPlace from '@/components/editInPlace'
import DateComponent from '@/components/ui/Date/DateFields.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { convertToLatLongOrder } from '@/helpers/geojson'
import { GEOREFERENCE_GEOLOCATE, GEOREFERENCE_WKT } from '@/constants/index.js'

export default {
  components: {
    RadialAnnotator,
    DateComponent,
    EditInPlace,
    VBtn
  },
  props: {
    list: {
      type: Array,
      default: () => []
    },
    header: {
      type: Array,
      default: () => []
    },
    destroy: {
      type: Boolean,
      default: true
    },
    deleteWarning: {
      type: Boolean,
      default: true
    },
    annotator: {
      type: Boolean,
      default: true
    },
    edit: {
      type: Boolean,
      default: false
    }
  },

  emits: ['delete', 'update', 'dateChanged'],

  methods: {
    deleteItem(item) {
      if (this.deleteWarning) {
        if (
          window.confirm(
            "You're trying to delete this record. Are you sure want to proceed?"
          )
        ) {
          this.$emit('delete', item)
        }
      } else {
        this.$emit('delete', item)
      }
    },
    getCoordinates(coordinates) {
      const flatten = coordinates.flat(1)

      if (typeof flatten[0] === 'number') {
        console.log(coordinates)
        return convertToLatLongOrder(coordinates)
      } else {
        return flatten.map((arr) => convertToLatLongOrder(arr))
      }
    },
    geojsonObject(object) {
      return object.geo_json
        ? object.geo_json
        : JSON.parse(object.geographic_item_attributes.shape)
    },
    getGeoJsonType(object) {
      return this.geojsonObject(object).geometry.type
    },
    isTmpWkt(object) {
      return object.type === GEOREFERENCE_WKT && object.tmpId
    },
    isTempGeolocate(object) {
      return object.type === GEOREFERENCE_GEOLOCATE && object.tmpId
    },
    getCoordinatesByType(object) {
      if (this.isTmpWkt(object)) {
        return object.wkt
      } else if (this.isTempGeolocate(object)) {
        return object.iframe_response
      } else {
        return this.getCoordinates(
          this.geojsonObject(object).geometry.coordinates
        )
      }
    }
  }
}
</script>
