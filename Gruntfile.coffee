module.exports = (grunt) ->
  'use strict'


  ############
  # plugins

  [
    'grunt-contrib-clean'
    'grunt-iced-coffee'
    'grunt-contrib-copy'
    'grunt-contrib-concat'
    'grunt-contrib-uglify'
  ].map (x) -> grunt.loadNpmTasks(x)

  # text files -> JSON
  grunt.registerMultiTask 'pack', 'pack text files into JSONP', ->
    path = require 'path'
    for x in @files
      o = {}
      for f in x.src
        name = path.basename f
        cont = grunt.file.read f, encoding: 'utf-8'
        o[name] = cont
      ret = ";var #{x.name}=#{JSON.stringify(o)};\n"
      grunt.file.write x.dest, ret, encoding: 'utf-8'

  # template
  grunt.registerMultiTask 'template', ->
    for x in @files
      cont = ''
      for src in x.src
        cont += grunt.template.process grunt.file.read(src, encoding: 'utf-8')
      cont = cont.replace(/\r\n/g, '\n')
      grunt.file.write(x.dest, cont, encoding: 'utf-8')


  ############
  # config

  grunt.initConfig new ->
    @pkg = grunt.file.readJSON('package.json')

    # default
    @clean =
      build: ['build/*']
      dist: ['dist/*']
    @coffee =
      options:
        bare: true
    @uglify =
      options:
        preserveComments: 'some'
    @pack = {}
    @template = {}
    @copy = {}
    @concat = {}

    # minify and join libraries
    @uglify.lib =
      options:
        mangle: false
      files: [
        {
          expand: true
          cwd: 'lib/'
          src: ['*.js', '!*.min.js']
          dest: 'build/lib/'
        }
      ]
    @copy.lib =
      files: [
        {
          expand: true
          cwd: 'lib/'
          src: '*.min.js'
          dest: 'build/lib/'
        }
      ]
    @concat.lib =
      src: 'build/lib/*.js'
      dest: 'build/lib.js'
    grunt.registerTask 'lib', [
      'uglify:lib'
      'copy:lib'
      'concat:lib'
    ]

    # pack HTML
    @pack.html =
      name: 'PACKED_HTML'
      src: 'src/**/*.html'
      dest: 'build/packed/html.js'
    grunt.registerTask 'pack-html', [
      'pack:html'
    ]

    # join all packed files
    @concat.pack =
      src: 'build/packed/*.js'
      dest: 'build/packed.js'
    grunt.registerTask 'pack-all', [
      'pack-html'
      'concat:pack'
    ]

    # main code
    @coffee.main =
      options:
        join: true
        # sourceMap: true
        runtime: 'window'
      files: [
        {src: 'src/*.{iced,coffee}', dest: 'build/main.js'}
      ]
    grunt.registerTask 'main', [
      'coffee:main'
    ]

    # make all-in-one script
    @concat.aio =
      files: [
        {
          src: [
            'build/lib.js'
            'build/packed.js'
            'build/main.js'
          ]
          dest: 'build/aio.js'
        }
      ]
    grunt.registerTask 'aio', [
      'concat:aio'
    ]

    # make userscript
    @template.gm =
      files: [
        {src: 'src/gm/metadata.js', dest: 'build/metadata.js'}
      ]
    @concat.gm =
      src: [
        'build/metadata.js'
        'build/aio.js'
      ]
      dest: "dist/gm/#{@pkg.name}.user.js"
    grunt.registerTask 'gm', [
      'template:gm'
      'concat:gm'
    ]

    @ # grunt.initConfig

  grunt.registerTask 'default', [
    'pack-all'
    'main'
    'aio'
    'gm'
  ]

  grunt.registerTask 'all', [
    'clean'
    'lib'
    'default'
  ]
