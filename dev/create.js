#!/usr/bin/env node

var argv = require('optimist').argv;
var fs = require('fs');
var mkdirp = require('mkdirp');
var module = argv.m || '';
var block = argv._[0];
var blockRoot = 'b';
var globalStyles = blockRoot + '/blocks.styl';
var globalJade = blockRoot + '/blocks.jade';

if (module) {
    if (!fs.existsSync(blockRoot + '/' + module)) {
        throw("Module " + module + " doesn't exists");
    }

    blockPath = [blockRoot, module, block].join('/');
}
else {
    blockPath = [blockRoot, block].join('/');
}

if(fs.existsSync(blockPath)) {
    throw('Block exits');
}


mkdirp.sync(blockPath + '/images');

blockName = block.split('/')[block.split('/').length-1];
fs.writeFileSync(blockPath + '/' + blockName + '.styl', '');
fs.writeFileSync(blockPath + '/' + blockName + '.ie.styl', '');
fs.writeFileSync(blockPath + '/' + blockName + '.uri.styl', '');
fs.writeFileSync(blockPath + '/' + blockName + '.js', '');
fs.writeFileSync(blockPath + '/' + blockName + '.jade', '');

var moduleBlockName = module.split('/')[module.split('/').length-1];
var moduleStyleFilename = [blockRoot, module, moduleBlockName + '.styl'].join('/');
var moduleJadeFilename = [blockRoot, module, moduleBlockName + '.jade'].join('/');

appendStyleTo = module ? moduleStyleFilename : globalStyles;
fs.appendFileSync(appendStyleTo, '\n@import "' + block + '/' + blockName + '"\n');

appendStyleTo = module ? moduleJadeFilename : globalJade;
fs.appendFileSync(appendStyleTo, '\ninclude ' + block + '/' + blockName + '\n');

console.log('Block ' + block + ' added to ' + appendStyleTo);