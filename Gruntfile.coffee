module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      compile:
        files:
          'build/js/on-site.js': 'src/coffee/on-site.coffee'
          'build/js/image-editor.js': 'src/coffee/image-editor.js'
          'extension/src/browser_action/fork.js': 'extension/src/browser_action/fork.coffee'
          'extension/src/bg/background.js': 'extension/src/bg/background.coffee'


    copy:
      main:
        cwd: 'src/'
        expand: true
        src: ['**/*.html']
        dest: 'build/'
        filter: 'isFile'

    watch:
      src:
        files: ['src/**/*','extension/src/**/*'],
        tasks: ['default']

  # Grunt coffee
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee', 'copy'])