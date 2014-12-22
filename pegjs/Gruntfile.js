module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    peg: {
      dice: {
        src: "dice.pegjs",
        dest: "dice.js"
      }
    },
  });

  grunt.loadNpmTasks('grunt-peg');
  grunt.loadNpmTasks('grunt-webpack');

};

