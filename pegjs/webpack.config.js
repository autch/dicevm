var BowerWebpackPlugin = require("bower-webpack-plugin");

module.exports = {
  entry: "./dice_web.js",
  output: {
    path: __dirname,
    filename: "dice_web.out.js"
  },

  plugins: [
    new BowerWebpackPlugin()
  ]
};

