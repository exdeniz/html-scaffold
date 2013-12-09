module.exports = (grunt) ->
    name                        = 'html-scaffold'


    tplDev                  = {}
    cssDev                  = {}
    cssDevIE7               = {}
    cssDevIE8               = {}
    cssDevIE                = {}

    jsDev                       = {}

    buildFolder         = '../build'
    tplBuild                = {}
    cssBuild                = {}
    cssCompress         = {}
    jsBuild                 = {}

    jqueryBuild     = "http://yandex.st/jquery/1.9.1/jquery.min.js"
    jqueryDev       = "js/libs/jquery.js"

    libs                        = []

    # pages
    tplDev['index.html']                                        = 'tpl/index.jade'

    tplBuild["#{buildFolder}/index.html"]   = 'tpl/index.jade'

    # styles
    cssDev["css/#{name}.css"]                           = 'b/blocks.styl'

    cssDevIE7["css/#{name}.ie7.css"] = 'b/**/*.ie7.styl'

    cssDevIE8["css/#{name}.ie8.css"] = 'b/**/*.ie8.styl'

    cssDevIE["css/#{name}.ie.css"] = 'b/**/*.ie.styl'

    cssCompress["#{buildFolder}/css/#{name}.min.css"]           = "css/#{name}.css"
    cssCompress["#{buildFolder}/css/#{name}.ie.min.css"]            = "css/#{name}.ie.css"
    cssCompress["#{buildFolder}/css/#{name}.ie7.min.css"]           = "css/#{name}.ie7.css"

    # logic written with coffee is compiled to one js
    jsDev["js/#{name}.js"]                               = 'b/**/*.coffe'

    # concatenated files will be uglyfied for build version
    jsBuild["#{buildFolder}/js/#{name}.min.js"] = "js/#{name}.js"
    jsBuild["#{buildFolder}/js/libs.min.js"] = "js/libs.js"

    # Image dir
    imageCompress = 'images/'

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        jade:
            dev:
                files: tplDev
                options:
                    pretty: true
                    data:
                        projectName: name
                        data:   grunt.file.readYAML 'data.yaml'
                        css:
                            common: "css/#{name}.prefix.css"
                            ie: "css/#{name}.ie.css"
                            ie7: "css/#{name}.ie7.css"
                        js: "js/#{name}.js"
                        plugins: "js/libs.js"
                        jquery: jqueryDev
            build:
                files: tplBuild
                options:
                    data:
                        projectName: name
                        data:   grunt.file.readYAML 'data.yaml'
                        css:
                            common: "css/#{name}.min.css"
                            ie: "css/#{name}.ie.min.css"
                            ie7: "css/#{name}.ie7.min.css"
                        js: "js/#{name}.min.js"
                        plugins: "js/libs.min.js"
                        jquery: jqueryBuild

        stylus:
            dev:
                files: cssDev
                options:
                    compress: false
            ie:
                files: [cssDevIE,cssDevIE7]
                options:
                    compress: false

        coffee:
            dev:
                files: jsDev

        uglify:
            build:
                files: jsBuild

        cssmin:
            build:
                files: cssCompress

        watch:
            jade:
                files: ['tpl/**/*.jade', 'b/**/*.jade', 'lib/**/*.jade', 'data.yaml']
                tasks: ['concat:data','jade:dev']
                #options:
                #livereload: true
            stylus:
                files: ['b/**/*.styl','!b/**/*.ie7.styl','!b/**/*.ie8.styl','!b/**/*.ie.styl']
                tasks: ['stylus:dev','autoprefixer:dev']
            stylusIE:
                files: ['b/**/*.styl']
                tasks: ['stylus:ie']
            coffee:
                files: ['b/**/*.coffee', 'lib/**/*.coffee']
                tasks: ['coffee']
                #options:
                #livereload: true
            concat:
                files: ['b/**/*.yaml']
                tasks: 'concat:data'
                #options:
                #livereload: true
            images:
                files: ['b/**/images/*.{png,jpg,gif}']
                tasks: 'imagemin'
                #options:
                #livereload: true
            autoprefixer:
                files: ['css/#{name}.css']
                task: 'autoprefixer:dev'
        concat:
            js:
                options:
                    separator: ';'
                dist:
                    src: ['b/**/*.js']
                    dest: 'js/libs.js'
            data:
                    src: ['b/**/*.yaml']
                    dest: 'data.yaml'

        copy:
            build:
                files: [{
                    expand: true
                    src: ['b/**', '!b/**/*.jade', '!b/**/*.styl', '!b/**/*.coffee', '!b/**/*.js']
                    dest: "#{buildFolder}/"
                }]
        imagemin:
            files:
                expand: true
                flatten: true
                cwd: 'b/'
                src: ['**/images/*.{png,jpg,gif}']
                dest: 'images/'


        connect:
          server:
            options:
              hostname: '*'
              port: 9001
              base: '.'

        styleinjector:
            dev:
                files:
                  src: ['css/**/*.prefix.css','**/*.html','/images/**/*.jpg','images/**/*.png','images/**/*.gif','js/**/*.js']
                options:
                    watchTask: true
        autoprefixer:
            dev:
                src: "css/#{name}.css"
                dest: "css/#{name}.prefix.css"
            ie7:
                src: "css/#{name}.ie7.css"
                dest: "css/#{name}.ie7.prefix.css"
                options:
                  browsers: ['ie 7']
        initBlock:
            options:
                element: '_'
                modifier: '__'
                preprocessor: true
                longModifier: true
            dev:
                src: ['index.html']
                dest: 'b/'



    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-cssmin'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-style-injector'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-contrib-imagemin'
    grunt.loadNpmTasks 'grunt-init-block'
    grunt.loadNpmTasks 'grunt-autoprefixer'

    grunt.registerTask 'default', ['connect:server','concat:data','jade:dev', 'stylus:dev','stylus:ie', 'initBlock:dev', 'coffee','imagemin','concat:js','autoprefixer','styleinjector','watch']
    grunt.registerTask 'build', ['jade:build', 'cssmin', 'uglify', 'copy:build']
    grunt.registerTask 'server', ['connect:server', 'watch']