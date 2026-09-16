const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const fs = require('fs');

const getFilesArray = (options) => {
    const rootDir = options.dir;
    const {extensions} = options;
    const exclude = options.exclude ? options.exclude : false;

    let regexpExtensions = extensions;

    if (Array.isArray(extensions)) {
        regexpExtensions = extensions.join('|');
    }

    let regular = new RegExp('.\\.' + regexpExtensions + '$');

    const filesArray = [];

    const getFiles = (innerOptions) => {
        const {dir} = innerOptions;

        let files = fs.readdirSync(dir);

        for (let file of files) {
            let fileName = dir + '/' + file;
            const isExclude = exclude ? fileName.indexOf(exclude) !== -1 : false;

            if (isExclude) {
                continue;
            }

            const isDirectory = fs.statSync(fileName).isDirectory();

            if (isDirectory) {
                getFiles({
                    dir: fileName,
                });
            } else if (regular.test(fileName)) {
                filesArray.push(fileName);
            }
        }

    };

    getFiles({
        dir: rootDir,
    });


    return filesArray;
};

const main = getFilesArray({
    dir: path.resolve(__dirname, './resources'),
    extensions: ['js', 'scss']
});

module.exports = {
    mode: 'development',
    entry: {
        main,
    },
    output: {
        filename: '[name]-[hash].js',
        path: path.resolve(__dirname, './public/dist'),
        clean: true,
    },
    devtool: 'source-map',
    module: {
        rules: [
            {
                test: /\.(png|jpg|svg|ttf|eot|woff|woff2|webp)$/,
                type: 'asset/resource',
                generator: {
                    filename: (normalModule) => {
                        let filePath = normalModule.module.resourceResolveData.relativePath;
                        filePath = filePath.replace('./public/', '/');
                        return filePath;
                    },
                    emit: false,
                },
            },
            {
                test: /\.js$/,
                loader: 'babel-loader',
                exclude: '/node_modules/'
            },
            {
                test: /\.css$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: 'css-loader'
                    },
                ],

            },
            {
                test: /\.scss$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: 'css-loader',
                    },
                    {
                        loader: 'sass-loader',
                    }
                ],
            },
        ],

    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: '[name]-[hash].css',
        }),
    ],
};
