'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const { Webpack } = require('@embroider/webpack');

module.exports = function (defaults) {
  const app = new EmberApp(defaults, {
    // Add options here
    'ember-cli-babel': {
      enableTypeScriptTransform: true,
    },
  });


  return require('@embroider/compat').compatBuild(app, Webpack, {
    extraPublicTrees: [],
    staticAddonTrees: true,
    staticAddonTestSupportTrees: true,
    staticHelpers: true,
    staticModifiers: true,
    staticComponents: true,
    staticEmberSource: true,
    splitControllers: true,
    splitRouteClasses: true,
    amdCompatibility: {
      es: [],
    },
    // splitAtRoutes: ['route.name'], // can also be a RegExp
    // packagerOptions: {
    //    webpackConfig: { }
    // }
  });
};
