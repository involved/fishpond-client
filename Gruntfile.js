module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      compile: {
        options:{
          join: true
        },
        files:{
          'build/<%= pkg.name %>-<%= pkg.version %>.js': ['src/*.coffee']
        }
      }
    },

    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> v<%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        src: 'build/<%= pkg.name %>-<%= pkg.version %>.js',
        dest: 'build/<%= pkg.name %>-<%= pkg.version %>.min.js'
      }
    },

    nodeunit: {
      all: ['test/*_test.coffee'],
      options: {}
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-git');
  grunt.loadNpmTasks('grunt-release');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');

  grunt.registerTask('default', ['test']);
  grunt.registerTask('build', ['coffee', 'uglify'])

  grunt.registerTask('test', 'runs tests', function(){
    grunt.log.write('Running test suite');
  });
};
