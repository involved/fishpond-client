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

    release: {
      options: {
        commitMessage: 'Release v<%= pkg.version %>',
        tagMessage: 'Release v<%= pkg.version %>'
      },
    },

    gitcommit:{
      release:{
        options:{
          message: "Release v<%= pkg.version %>"
        },
        files: {
          src: ['build/*.js', 'package.json']
        },
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
  grunt.loadNpmTasks('grunt-git');

  grunt.registerTask('default', ['test']);
  grunt.registerTask('build', ['clean:build', 'coffee:compile', 'concat:build', 'uglify:build'])
  grunt.registerTask('release:patch', ['test', 'release:bump:patch', 'build', 'gitcommit:release', 'release:tag:pushTags'])
  grunt.registerTask('release:minor', ['test', 'release:bump:minor', 'build', 'gitcommit:release', 'release:tag:pushTags'])
  grunt.registerTask('release:major', ['test', 'release:bump:major', 'build', 'gitcommit:release', 'release:tag:pushTags'])

  grunt.registerTask('test', 'runs tests', function(){
    grunt.log.write('Running test suite');
  });
};
