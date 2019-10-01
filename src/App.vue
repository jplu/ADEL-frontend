<template>
  <v-app id="inspire">
    <v-navigation-drawer
        v-model="sidebar"
        app
    >
      <v-list dense>
        <v-list-item
          v-for="item in menuItems"
          :key="item.title"
          :to="item.path">
          <v-list-item-action>
            <v-icon>{{ item.icon }}</v-icon>
          </v-list-item-action>
          <v-list-item-content>{{ item.title }}</v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-app-bar
        app
        dark
    >
      <v-app-bar-nav-icon @click.stop="sidebar = !sidebar"></v-app-bar-nav-icon>
      <v-toolbar-title>Application</v-toolbar-title>
    </v-app-bar>

    <v-content>
      <router-view></router-view>
    </v-content>
    <v-footer
        app
    >
      <span>&copy; {{ new Date().getFullYear() }}</span>
    </v-footer>
  </v-app>
</template>

<script>
  export default {
    name: "App",
    data(){
      return {
        appTitle: 'ADEL',
        sidebar: false,
        menuItems: [
          { title: 'Home', path: '/', icon: 'home' },
          { title: 'Demo', path: '/demo', icon: 'dashboard' },
          { title: 'About', path: '/about', icon: 'mdi-contact-mail' }
        ]
      }
    },
  };
</script>
<style>

</style>
