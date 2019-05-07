<template>
  <div class="text">
    <v-form ref="form"
            v-model="valid"
            lazy-validation>
      <v-textarea
          label="Text"
          name="input-7-1"
          auto-grow
          append-icon="description"
          v-model="text"
          :rules="[v => !!v || 'Text is required']"
          required
      ></v-textarea>
      <v-select
          v-model="select"
          :hint="`${select.profile}`"
          :items="profiles"
          item-text="name"
          item-value="profile"
          label="Profile"
          :rules="[v => JSON.stringify(v) != JSON.stringify({}) || 'Profile is required']"
          persistent-hint
          return-object
          single-line
          required
      ></v-select>
      <br />
      <v-btn
          :disabled="!valid"
          color="success"
          @click="validate"
      >
        Recognize
      </v-btn>
    </v-form>
    <div v-if="seen">
      <v-container fluid>
        <v-layout row wrap>
          <v-flex xs1 v-for="item in types" :key="item.type">
            <v-checkbox
                v-model="checkedValues"
                :label="item.type"
                :value="item.type"
                :color="item.color"
                v-on:change="parse"
            ></v-checkbox>
          </v-flex>
        </v-layout>
      </v-container>
    </div>
    <br />
    <div v-if="seen" v-html="render" class="entities">
    </div>
  </div>
</template>

<script>
  import axios from 'axios/index'

  export default {
    name: "ADEL",
    data () {
      return {
        checkedValues: [],
        response: null,
        valid: true,
        seen: false,
        render: null,
        types: [],
        mapColors: {},
        text: null,
        select: {},
        profiles: [
          {name: "Default", profile: "en"},
          {name: "Full", profile: "en-full"}
        ]
      }
    },
    methods: {
      validate() {
        if (this.$refs.form.validate()) {
          this.sendData()
        }
      },
      getRandomColor() {
        let letters = '0123456789ABCDEF'
        let color = '#'

        for (let i = 0; i < 6; i++) {
          color += letters[Math.floor(Math.random() * 16)]
        }

        return color
      },
      sendData () {
        axios({ 'method': 'POST',
                'url': process.env.VUE_APP_API_ADDRESS + '/adel/api/v2/recognize',
                'data': { 'text': this.text },
                headers: { 'content-type': 'application/json' }
              }).then((result) => {
          this.response = result.data
          this.seen = true

          let colors = []
          let tmpTypes = []
          this.types = []

          for (let entity in this.response.entities) {
            if (!tmpTypes.includes(this.response.entities[entity].type)) {
              tmpTypes.push(this.response.entities[entity].type)

              let color = this.getRandomColor()

              while (colors.includes(color)) {
                color = this.getRandomColor()
              }

              colors.push(color)
            }
          }

          for (let i = 0; i < tmpTypes.length; i++) {
            this.mapColors[tmpTypes[i]] = colors[i]
            this.types.push({type: tmpTypes[i], color: colors[i]})
          }

          this.checkedValues = [...tmpTypes]

          this.parse()
        }, error => {
          /*eslint no-console: ["error", { allow: ["warn", "error"] }] */
          console.error(error)
        })


        /*this.seen = true
        this.response = {entities:[{phrase:"Barack Obama",cleanPhrase:"Barack Obama",type:"PER",startOffset:0,endOffset:12},{phrase:"Hawaii",cleanPhrase:"Hawaii",type:"LOC",startOffset:25,endOffset:31},{phrase:"He",cleanPhrase:"Barack Obama",type:"PER",startOffset:33,endOffset:35},{phrase:"2008",cleanPhrase:"2008",type:"MISC",startOffset:61,endOffset:65},{phrase:"Hawaii",cleanPhrase:"Hawaii",type:"PER",startOffset:67,endOffset:73}]}
        */
      },
      replaceBetween(start, end, what, strg) {
        return strg.substring(0, start) + what + strg.substring(end)
      },
      parse () {
        this.render = this.text

        let entities = this.response.entities.sort(function (a, b) {
          return b.startOffset - a.startOffset
        })

        for (let entity in entities) {
          let color = this.mapColors[entities[entity].type]
          let type = entities[entity].type

          if (this.checkedValues.includes(type)) {
            let toReplace = "<span entity=\"" + type + "\" style=\"background: " + color + ";\">" +
                            entities[entity].phrase + "</span>"
            this.render = this.replaceBetween(entities[entity].startOffset,
                                              entities[entity].endOffset,
                                              toReplace, this.render)
          }
        }
      }
    }
  }
</script>

<style scoped>
  div {
    position: relative;
    width: 98%;
    margin-left: 10px;
  }
  .entities >>> [entity] {
    padding: .2em .3em;
    margin: 0 0.25em;
    line-height: 1;
    display: inline-block;
    border-radius: 0.25em;
  }

  .entities >>> [entity]:after {
    box-sizing: border-box;
    content: attr(entity);
    font-size: .55em;
    line-height: 1;
    padding: .35em .35em;
    border-radius: .35em;
    text-transform: uppercase;
    display: inline-block;
    vertical-align: middle;
    margin: 0 0 .15rem .5rem;
    background: #fff;
    font-weight: 700
  }
  .entities {
    line-height: 2.5;
    direction: ltr
  }
</style>
