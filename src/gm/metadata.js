// Copyright (c) <%= grunt.template.today('yyyy') %>, <%= pkg.author.name %>. (MIT Licensed)
// ==UserScript==
// @name          <%= pkg.name %>
// @namespace     http://github.com/smilekzs
// @version       <%= pkg.version %>
// @description   <%= pkg.description %>
// @grant         GM_xmlhttpRequest
// @match         *://github.com/*
// @match         *://gist.github.com/*
// ==/UserScript==
// vim: set nowrap ft= : 

// http://stackoverflow.com/questions/4190442/run-greasemonkey-script-only-once-per-page-load
if (window.top != window.self) return;  //don't run on frames or iframes
