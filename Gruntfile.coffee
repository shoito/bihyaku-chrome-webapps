#jshint camelcase: false

# Generated on 2013-05-11 using generator-chrome-extension 0.1.1
"use strict"
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)


# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
  
  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  # configurable paths
  yeomanConfig =
    app: "app"
    dist: "dist"

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee"]
        tasks: ["build"]

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      less:
        files: ["<%= yeoman.app %>/styles/**/*.less"]
        tasks: ["build"]

    connect:
      options:
        port: 9000
        
        # change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "package", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
        ]

      server: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/{,*/}*.js", "test/spec/{,*/}*.js"]

    mocha:
      all:
        options:
          run: true
          urls: ["http://localhost:<%= connect.options.port %>/index.html"]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
          src: "{,*/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]

      test:
        files: [
          expand: true
          cwd: "test/spec"
          src: "{,*/}*.coffee"
          dest: ".tmp/spec"
          ext: ".js"
        ]

    compass:
      options:
        sassDir: "<%= yeoman.app %>/styles"
        cssDir: ".tmp/styles"
        imagesDir: "<%= yeoman.app %>/images"
        javascriptsDir: "<%= yeoman.app %>/scripts"
        fontsDir: "<%= yeoman.app %>/styles/fonts"
        importPath: "app/components"
        relativeAssets: true

      dist: {}
      server:
        options:
          debugInfo: true

    less:
      production:
        files:
          "<%= yeoman.app %>/styles/*.css": "<%= yeoman.app %>/styles/{,*/}*.less"
        options:
          basePath: "app/styles"
          yuicompress: true
    
    # not used since Uglify task does concat,
    # but still available if needed
    #concat: {
    #            dist: {}
    #        },
    
    # not enabled since usemin task does concat and uglify
    # check index.html to edit your build targets
    # enable this task if you prefer defining your build targets here
    #uglify: {
    #            dist: {}
    #        },
    useminPrepare:
      html: ["<%= yeoman.app %>/index.html"]
      options:
        dest: "<%= yeoman.dist %>"

    usemin:
      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dist %>/styles/{,*/}*.css"]
      options:
        dirs: ["<%= yeoman.dist %>"]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= yeoman.dist %>/images"
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.svg"
          dest: "<%= yeoman.dist %>/images"
        ]

    cssmin:
      dist:
        files:
          "<%= yeoman.dist %>/styles/main.css": [".tmp/styles/{,*/}*.css", "<%= yeoman.app %>/styles/{,*/}*.css"]

    htmlmin:
      dist:
        options: {}
        
        #removeCommentsFromCDATA: true,
        #                    // https://github.com/yeoman/grunt-usemin/issues/44
        #                    //collapseWhitespace: true,
        #                    collapseBooleanAttributes: true,
        #                    removeAttributeQuotes: true,
        #                    removeRedundantAttributes: true,
        #                    useShortDoctype: true,
        #                    removeEmptyAttributes: true,
        #                    removeOptionalTags: true
        files: [
          expand: true
          cwd: "<%= yeoman.app %>"
          src: "*.html"
          dest: "<%= yeoman.dist %>"
        ]

    
    # Put files not handled in other tasks here
    copy:
      coffee:
        files: [
          expand: true
          dot: true
          cwd: ".tmp"
          dest: "<%= yeoman.dist %>"
          src: [
            "scripts/{,*/}*.js"
          ]
        ]
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.dist %>"
          src: [
            "*.{ico,txt,yaml}"
            "images/{,*/}*.{webp,gif}"
            "_locales/{,*/}*.json"
            "scripts/{,*/}*.js"
            "components/jquery/jquery.js"
            "components/eventEmitter/EventEmitter.js"
            "components/eventie/eventie.js"
            "components/imagesloaded/imagesloaded.js"
            "components/font-awesome/css/font-awesome.css"
            "components/font-awesome/font/fontawesome-webfont.woff"
          ]
        ]

    concurrent:
      server: ["coffee:dist", "less"]
      test: ["coffee", "less"]
      dist: ["coffee", "less", "imagemin", "svgmin", "htmlmin", "cssmin"]

    compress:
      dist:
        options:
          archive: "package/bihyaku.zip"

        files: [
          expand: true
          cwd: "dist/"
          src: ["**"]
          dest: ""
        ]

  grunt.renameTask "regarde", "watch"
  grunt.registerTask "prepareManifest", ->
    scripts = []
    concat = grunt.config("concat") or dist:
      files: {}

    uglify = grunt.config("uglify") or dist:
      files: {}

    grunt.config "concat", concat
    grunt.config "uglify", uglify

  grunt.registerTask "manifest", ->
    manifest = grunt.file.readJSON(yeomanConfig.app + "/manifest.json")
    grunt.file.write yeomanConfig.dist + "/manifest.json", JSON.stringify(manifest, null, 2)

  grunt.registerTask "test", ["clean:server", "concurrent:test", "connect:test", "mocha"]
  grunt.registerTask "build", ["clean:dist", "prepareManifest", "useminPrepare", "concurrent:dist", "concat", "uglify", "copy:coffee", "copy:dist", "usemin", "manifest", "compress"]
  grunt.registerTask "default", ["jshint", "test", "build"]
