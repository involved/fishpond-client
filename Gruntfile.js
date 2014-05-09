module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      compile: {
        options:{
          join: true
        },
        files:{
          'tmp/<%= pkg.name %>-core-<%= pkg.version %>.js': ['src/**/*.coffee']
        }
      }
    },

    concat: {
      options: {
        banner: '/*! <%= pkg.name %> v<%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build:{
        src: ["lib/*.js", "tmp/*.js"],
        dest: "build/<%= pkg.name %>-<%= pkg.version %>.js"
      }
    },

    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> v<%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        files: {
          'build/<%= pkg.name %>-<%= pkg.version %>.min.js': ['build/<%= pkg.name %>-<%= pkg.version %>.js']
        }
      }
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
  grunt.loadNpmTasks('grunt-release');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');

  grunt.registerTask('default', ['test']);
  grunt.registerTask('build', ['coffee:compile', 'concat:build', 'uglify:build'])

  grunt.registerTask('test', 'runs tests', function(){
    grunt.log.write('Running test suite');
  });
};
