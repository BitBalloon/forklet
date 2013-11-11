module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      compile:
        files:
          'build/on-site/js/on-site.js': 'src/coffee/on-site.coffee'
          'build/on-site/js/image-editor.js': 'src/coffee/image-editor.js'
          'build/extension/src/browser_action/fork.js': 'extension/src/browser_action/fork.coffee'
          'build/extension/src/bg/background.js': 'extension/src/bg/background.coffee'
          'build/extension/src/bg/pageslurper.js': 'extension/src/bg/pageslurper.coffee'


    copy:
      main:
        files: [
          {
            cwd: 'src/'
            expand: true
            src: ['**/*.html', '**/*.png']
            dest: 'build/on-site'
            filter: 'isFile'
          },
          {
            cwd: 'extension/'
            expand: true
            src: ['**/*.html', '**/*.*.js', '**/*.json', '**/*.png']
            dest: 'build/extension'
            filter: 'isFile'
          }
        ]


    watch:
      src:
        files: ['src/**/*','extension/src/**/*'],
        tasks: ['default']

  # Grunt coffee
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee', 'copy'])