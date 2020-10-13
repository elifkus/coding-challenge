"use strict"

const path = require("path")
const HtmlWebpackPlugin = require("html-webpack-plugin")
const { CleanWebpackPlugin } = require("clean-webpack-plugin")
const webpack = require('webpack')
const isWebpackDevServer = process.argv.some(a => path.basename(a) === 'webpack-dev-server')
const isWatch = process.argv.some(a => a === '--watch')

const plugins =
    isWebpackDevServer || !isWatch ? [] : [
        function () {
            this.plugin('done', function (stats) {
                process.stderr.write(stats.toString('errors-only'))
            })
        }
    ]

module.exports = {
    entry: './src/index.js',

    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'bundle.js'
    },

    module: {
        rules: [
            {
                test: /\.purs$/,
                use: [
                    {
                        loader: 'purs-loader',
                        options: {
                            src: [
                                'src/**/*.purs'
                            ],
                            spago: true,
                            watch: isWebpackDevServer || isWatch,
                            pscIde: true
                        }
                    }
                ]
            },
            {
                test: /\.css$/i,
                use: ['style-loader', 'css-loader'],
            }
        ],
    },

    resolve: {
        modules: ['node_modules'],
        extensions: ['.purs', '.js']
    },
    plugins: [
        new webpack.LoaderOptionsPlugin({
            debug: true
        }),
        // This plugin deletes (cleans) the output folder
        // `./dist` in our case
        new CleanWebpackPlugin(),
        new webpack.DefinePlugin({
            'process.env.BASE_URL': JSON.stringify(process.env.BASE_URL)
        }),
        // This plugin allows us to use a HTML file template.
        // In the settings we specify its title and 'entry'
        // specifies a script to be injected into the template
        new HtmlWebpackPlugin({
            title: "Hivemind Tweet UI",
            template: path.resolve(__dirname, "src", "index.html"),
        }),
    ],
}
