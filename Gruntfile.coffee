#jshint camelcase: false

# Generated on 2013-05-11 using generator-chrome-extension 0.1.1
"use strict"
LIVERELOAD_PORT = 35729
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
      html:
        files: ["<%= yeoman.app %>/{,*/}*.html"]
        tasks: ["build"]
        options:
          livereload: LIVERELOAD_PORT

      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee"]
        tasks: ["build"]
        options:
          livereload: LIVERELOAD_PORT

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      less:
        files: ["<%= yeoman.app %>/styles/{,*/}*.{less,css}"]
        tasks: ["build"]
        options:
          livereload: LIVERELOAD_PORT

    connect:
      options:
        port: 3501

      livereload:
        options:
          middleware: (connect, options) ->
            return [
              mountFolder connect, "dist"
            ]
      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

    open:
      server:
        url: "http://localhost:<%= connect.options.port %>"

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
          src: "index.html"
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
            "scripts/main.js"
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
            "components/jquery/*.js"
            "components/font-awesome/css/font-awesome*.css"
            "components/font-awesome/font/fontawesome-webfont.*"
          ]
        ]

    concat:
      dist:
        src: [
          "<%= yeoman.app %>/components/eventie/eventie.js"
          "<%= yeoman.app %>/components/eventEmitter/EventEmitter.min.js"
          "<%= yeoman.app %>/components/imagesloaded/imagesloaded.js"
          "<%= yeoman.app %>/scripts/jquery.wookmark.js"
          ".tmp/scripts/bijin.js"
        ]
        dest: ".tmp/scripts/main.js"
        separator: ";"

    uglify:
      dist:
        files:
          "<%= yeoman.dist %>/scripts/main.min.js": [".tmp/scripts/main.js"]

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
  grunt.registerTask "server", (target) ->
    grunt.task.run [
      "build"
      "connect:livereload"
      "open:server"
      "watch"
    ]
  grunt.registerTask "test", ["clean:server", "concurrent:test", "connect:test", "mocha"]
  grunt.registerTask "build", ["clean:dist", "useminPrepare", "concurrent:dist", "concat", "uglify", "copy:coffee", "copy:dist", "usemin", "compress"]
  grunt.registerTask "default", ["jshint", "test", "build"]
