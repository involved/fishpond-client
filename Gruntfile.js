module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      compile: {
        options:{
          join: true
        },
        files:{
          'tmp/<%= pkg.name %>-core.js': ['src/**/*.coffee']
        }
      }
    },

    concat: {
      options: {
        banner: '/*! <%= pkg.name %> v<%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build:{
        src: ["lib/*.js", "tmp/*.js"],
        dest: "build/<%= pkg.name %>.js"
      }
    },

    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> v<%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        files: {
          'build/<%= pkg.name %>.min.js': ['build/<%= pkg.name %>.js']
        }
      }
    },

    clean:{
      build: ["tmp/*.js", "build/*.js"]
    },

    'release-it':{
      options:{
        commitMessage: "Release v<%= pkg.version %>",
        tagName: "v<%= pkg.version %>",
        tagAnnotation: "Release v<%= pkg.version %>",
        buildCommand: 'grunt build',
        publish: false
      },
    },

    nodeunit: {
      all: ['test/*_test.coffee'],
      options: {}
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-git');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');
  grunt.loadNpmTasks('grunt-release-steps');
  grunt.loadNpmTasks('grunt-contrib-clean');

  grunt.registerTask('default', ['test']);
  grunt.registerTask('build', ['clean:build', 'coffee:compile', 'concat:build', 'uglify:build'])
  grunt.registerTask('release:patch', ['release:bump:patch', 'build', 'release:add:commit:tag:pushTags'])
  grunt.registerTask('release:minor', ['release:bump:minor', 'build', 'release:add:commit:tag:pushTags'])
  grunt.registerTask('release:major', ['release:bump:major', 'build', 'release:add:commit:tag:pushTags'])

  grunt.registerTask('test', 'runs tests', function(){
    grunt.log.write('Running test suite');
  });
};
